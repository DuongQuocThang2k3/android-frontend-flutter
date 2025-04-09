import 'package:flutter/material.dart';
import 'package:the_cherry_pet_shop/models/petItem.dart';

import '../../pet_list/cache_pet.dart';

class AdminPetSelectionScreen extends StatefulWidget {
  const AdminPetSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AdminPetSelectionScreen> createState() =>
      _AdminPetSelectionScreenState();
}

class _AdminPetSelectionScreenState extends State<AdminPetSelectionScreen> {
  List<PetItem> _pets = [];
  List<PetItem> _filteredPets = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  PetItem? _selectedPet;

  @override
  void initState() {
    super.initState();
    _loadPets();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredPets = _pets;
      });
    } else {
      setState(() {
        _filteredPets = _pets
            .where((pet) => pet.name.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pets = await CachePet.loadPets();
      setState(() {
        _pets = pets;
        _filteredPets = pets;
      });
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

  void _confirmSelection() {
    if (_selectedPet != null) {
      Navigator.pop(context, _selectedPet);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thú cưng')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Thú cưng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Thanh tìm kiếm
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Tìm kiếm thú cưng',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown hiển thị danh sách thú cưng đã lọc
                      DropdownButtonFormField<PetItem>(
                        isExpanded: true,
                        hint: const Text('Chọn thú cưng'),
                        value: _selectedPet,
                        items: _filteredPets
                            .map((pet) => DropdownMenuItem<PetItem>(
                                  value: pet,
                                  child: Text(pet.name.isNotEmpty
                                      ? pet.name
                                      : 'Không có tên'),
                                ))
                            .toList(),
                        onChanged: (pet) {
                          setState(() {
                            _selectedPet = pet;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn thú cưng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _confirmSelection,
                        child: const Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
