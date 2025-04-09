import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../models/petItem.dart';
import '../../../services/api_client.dart';
import 'add_or_edit_pet_screen.dart';
import 'cache_pet.dart';

class AdminPetList extends StatefulWidget {
  const AdminPetList({Key? key}) : super(key: key);

  @override
  State<AdminPetList> createState() => _AdminPetListState();
}

class _AdminPetListState extends State<AdminPetList> {
  final ApiClient _api = ApiClient();
  List<PetItem> _pets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Đọc cache trước khi gọi API
    _loadLocalCache().then((_) {
      _loadPets();
    });
  }

  Future<void> _loadLocalCache() async {
    final cachedPets = await CachePet.loadPets();
    if (cachedPets.isNotEmpty) {
      setState(() {
        _pets = cachedPets;
      });
    }
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
          final pets = data.map((e) => PetItem.fromJson(e)).toList();
          setState(() {
            _pets = pets;
          });
          // Cập nhật cache sau khi tải xong
          await CachePet.savePets(_pets);
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
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        // Xóa thành công (204 No Content cũng thành công)
        setState(() {
          _pets.removeWhere((p) => p.petId == id);
        });
        // Cập nhật cache sau khi xóa
        await CachePet.savePets(_pets);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Xóa thành công',
              style: TextStyle(fontSize: 13),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Server error: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e', style: const TextStyle(fontSize: 13)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(PetItem pet) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận', style: TextStyle(fontSize: 13)),
        content: Text('Bạn có chắc chắn muốn xóa "${pet.name}"?',
            style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(fontSize: 13))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(pet.petId);
            },
            child: const Text('Xóa',
                style: TextStyle(fontSize: 13, color: Colors.red)),
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
    if (changed == true) {
      _loadPets();
    }
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) return _buildPlaceholder();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Pets List',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadPets,
            tooltip: 'Làm mới danh sách',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: () => _openForm(),
            tooltip: 'Thêm thú cưng mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _pets.isEmpty
                  ? _buildEmptyView()
                  : _buildPetsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadPets,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Thử lại', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          const Text(
            'Chưa có thú cưng nào',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhấn nút + để thêm thú cưng mới',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Thêm thú cưng', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        final pet = _pets[index];
        final imageUrl = pet.images.isNotEmpty ? pet.images.first : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Image
                _buildImage(imageUrl),
                const SizedBox(width: 8),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: pet.status == 'Available'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pet.status,
                              style: TextStyle(
                                fontSize: 13,
                                color: pet.status == 'Available'
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Age and price
                      Text(
                        'Tuổi: ${pet.age} • Giá: ${pet.price.toStringAsFixed(0)} đ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Description
                      Text(
                        pet.description,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openForm(pet: pet),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Sửa',
                                  style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _confirmDelete(pet),
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Xóa',
                                  style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
