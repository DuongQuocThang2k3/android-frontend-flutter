import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const PetListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  late Future<List<dynamic>> _pets;

  @override
  void initState() {
    super.initState();
    _pets = _fetchPetsByCategory(widget.categoryId);
  }

  Future<List<dynamic>> _fetchPetsByCategory(int categoryId) async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('Pet'); // GET /Pet
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.where((pet) => pet['categoryId'] == categoryId).toList();
      } else {
        throw Exception('Failed to load pets (status ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách ${widget.categoryName}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load pets: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final pets = snapshot.data!;
            if (pets.isEmpty) {
              return Center(
                child: Text(
                  'No pets found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return ListView.separated(
              itemCount: pets.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: pet['images'] != null && pet['images'].isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pet['images'][0]['url'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            ),
                          )
                        : _buildPlaceholder(),
                    title: Text(
                      '${index + 1}. ${pet['name']}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Giá: ${pet['price']} VND\nTình trạng: ${pet['status']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetDetailScreen(pet: pet),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No pets found',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.pets,
        color: Colors.white,
      ),
    );
  }
}
