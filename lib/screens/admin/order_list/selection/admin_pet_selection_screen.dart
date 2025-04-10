import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../models/petItem.dart';
import '../../../../services/api_client.dart';
import '../../pet_list/cache_pet.dart';

class PetSelectionWidget extends StatefulWidget {
  /// Callback trả về đối tượng được chọn (hoặc null nếu cần)
  final Function(PetItem?)? onSelected;

  const PetSelectionWidget({Key? key, this.onSelected}) : super(key: key);

  @override
  _PetSelectionWidgetState createState() => _PetSelectionWidgetState();
}

class _PetSelectionWidgetState extends State<PetSelectionWidget> {
  final ApiClient _api = ApiClient();
  List<PetItem> _pets = [];
  List<PetItem> _filteredPets = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  PetItem? _selectedPet;
  int _quantity = 1; // Số lượng mặc định khi chọn

  @override
  void initState() {
    super.initState();
    // Đọc dữ liệu từ cache trước, nếu có (bạn có thể bỏ cache nếu không cần)
    _loadLocalCache().then((_) {
      _loadPets();
    });
    // Lắng nghe thay đổi tìm kiếm
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredPets = query.isEmpty
            ? _pets
            : _pets.where((pet) => pet.name.toLowerCase().contains(query)).toList();
      });
    });
  }

  Future<void> _loadLocalCache() async {
    final cachedPets = await CachePet.loadPets();
    if (cachedPets.isNotEmpty) {
      setState(() {
        _pets = cachedPets;
        _filteredPets = cachedPets;
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
          final pets = data
              .map((e) => PetItem.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _pets = pets;
            _filteredPets = pets;
          });
          // Cập nhật cache sau khi lấy dữ liệu thành công
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

  void _incrementQuantity() {
    setState(() {
      _quantity += 1;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity -= 1;
      });
    }
  }

  double _calculateTotal() {
    // Giả sử pet.price là kiểu số (double); nếu null thì trả về 0
    final price = _selectedPet?.price ?? 0;
    return price * _quantity;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Lỗi: $_error',
          style: const TextStyle(fontSize: 13, color: Colors.red),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 8),
          // Dropdown hiển thị danh sách thú cưng đã lọc
          DropdownButtonFormField<PetItem>(
            isExpanded: true,
            hint: const Text('Chọn thú cưng'),
            value: _selectedPet,
            items: _filteredPets.map((pet) {
              return DropdownMenuItem<PetItem>(
                value: pet,
                child: Text(pet.name.isNotEmpty ? pet.name : 'Không có tên'),
              );
            }).toList(),
            onChanged: (pet) {
              setState(() {
                _selectedPet = pet;
                _quantity = 1; // Reset số lượng mỗi khi chọn thú cưng mới
              });
              if (widget.onSelected != null) {
                widget.onSelected!(pet);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Vui lòng chọn thú cưng';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          // Hiển thị số lượng option đã load
          Text(
            'Số lượng thú cưng đã load: ${_filteredPets.length}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Nếu đã chọn thú cưng thì hiển thị thông tin chi tiết (name, price, số lượng chọn, total)
          if (_selectedPet != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin tên và giá
                    Text(
                      'Tên: ${_selectedPet!.name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Giá: ${_selectedPet!.price.toString()} VND',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    // Nhập số lượng bằng nút +/-
                    Row(
                      children: [
                        const Text(
                          'Số lượng:',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        // Nút giảm số lượng
                        IconButton(
                          onPressed: _decrementQuantity,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          _quantity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        // Nút tăng số lượng
                        IconButton(
                          onPressed: _incrementQuantity,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Tổng tiền
                    Text(
                      'Tổng: ${_calculateTotal().toStringAsFixed(2)} VND',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
