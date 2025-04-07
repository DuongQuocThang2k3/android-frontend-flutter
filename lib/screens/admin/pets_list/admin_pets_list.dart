import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../models/petItem.dart';
import '../../../services/api_client.dart';
import 'add_or_edit_pet_screen.dart';

class AdminPetsList extends StatefulWidget {
  const AdminPetsList({Key? key}) : super(key: key);

  @override
  State<AdminPetsList> createState() => _AdminPetsListState();
}

class _AdminPetsListState extends State<AdminPetsList> {
  final ApiClient _api = ApiClient();
  List<PetItem> _pets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await _api.get('Pet');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          setState(() {
            _pets = data.map((e) => PetItem.fromJson(e)).toList();
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePet(int id) async {
    try {
      final resp = await _api.delete('Pet/$id');
      if (resp.statusCode == 200) {
        setState(() {
          _pets.removeWhere((p) => p.petId == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Server error: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(PetItem pet) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc chắn muốn xóa "${pet.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(pet.petId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({PetItem? pet}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddOrEditPetScreen(pet: pet)),
    );
    if (changed == true) _loadPets();
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) return _buildPlaceholder();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.pets, color: Colors.grey, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thú cưng'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPets)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _pets.isEmpty
                  ? const Center(child: Text('Chưa có thú cưng'))
                  : ListView.separated(
                      itemCount: _pets.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final pet = _pets[i];
                        final thumb =
                            pet.images.isNotEmpty ? pet.images.first : null;
                        return ListTile(
                          leading: _buildImage(thumb),
                          title: Text(pet.name),
                          subtitle: Text('${pet.age} tuổi • ${pet.price} đ'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openForm(pet: pet)),
                              IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _confirmDelete(pet)),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
