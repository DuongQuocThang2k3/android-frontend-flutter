import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config_url.dart';

class AdminPetsList extends StatefulWidget {
  const AdminPetsList({super.key});

  @override
  State<AdminPetsList> createState() => _AdminPetsListState();
}

class _AdminPetsListState extends State<AdminPetsList> {
  List<dynamic> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> _fetchPets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? token = await _getToken();
      final headers = token != null
          ? {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            }
          : {'Content-Type': 'application/json'};

      final response = await http.get(
        Uri.parse('${Config_URL.baseUrl}Pet'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          _pets = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Không thể tải danh sách thú cưng. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePet(int petId) async {
    try {
      String? token = await _getToken();
      final headers = token != null
          ? {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            }
          : {'Content-Type': 'application/json'};

      final response = await http.delete(
        Uri.parse('${Config_URL.baseUrl}Pet/$petId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          _pets.removeWhere((pet) => pet['petId'] == petId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa thú cưng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
            'Không thể xóa thú cưng. Mã lỗi: ${response.statusCode}');
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

  Future<void> _addOrEditPet({Map<String, dynamic>? pet}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditPetScreen(pet: pet),
      ),
    );

    if (result == true) {
      _fetchPets();
    }
  }

  void _showDeleteConfirmation(int petId, String petName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thú cưng "$petName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(petId);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý thú cưng',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPets,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _pets.isEmpty
                  ? _buildEmptyView()
                  : _buildPetList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditPet(),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add),
        tooltip: 'Thêm thú cưng mới',
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchPets,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có thú cưng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn nút + để thêm thú cưng mới',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Thay đổi từ GridView sang ListView
  Widget _buildPetList() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.separated(
        itemCount: _pets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final pet = _pets[index];
          final imageUrl = (pet['images'] != null && pet['images'].isNotEmpty)
              ? pet['images'][0]['url']
              : null;

          return _buildPetCard(pet, imageUrl);
        },
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet, String? imageUrl) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image section
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(height: 180);
                          },
                        )
                      : _buildPlaceholder(height: 180),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pet['price']} đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row with name and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pet['name'] ?? 'Không có tên',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pet['status'] == 'Available'
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pet['status'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: pet['status'] == 'Available'
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tuổi: ${pet['age'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pet['description'] ?? 'Không có mô tả',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions section
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _addOrEditPet(pet: pet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sửa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDeleteConfirmation(
                      pet['petId'],
                      pet['name'],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({double? height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }
}

class AddOrEditPetScreen extends StatefulWidget {
  final Map<String, dynamic>? pet;

  const AddOrEditPetScreen({super.key, this.pet});

  @override
  State<AddOrEditPetScreen> createState() => _AddOrEditPetScreenState();
}

class _AddOrEditPetScreenState extends State<AddOrEditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  String _status = 'Available';
  bool _isSubmitting = false;

  final List<String> _statusOptions = [
    'Available',
    'Adopted',
    'Reserved',
    'Unavailable'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?['name'] ?? '');
    _ageController =
        TextEditingController(text: widget.pet?['age']?.toString() ?? '');
    _priceController =
        TextEditingController(text: widget.pet?['price']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.pet?['description'] ?? '');
    _imageController = TextEditingController(
      text: widget.pet?['images']?.isNotEmpty == true
          ? widget.pet!['images'][0]['url']
          : '',
    );

    if (widget.pet != null && widget.pet!['status'] != null) {
      _status = widget.pet!['status'];
    }
  }

  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEditing = widget.pet != null;
    final url = isEditing
        ? Uri.parse('${Config_URL.baseUrl}Pet/${widget.pet!['petId']}')
        : Uri.parse('${Config_URL.baseUrl}Pet');

    final petData = {
      'petId': isEditing ? widget.pet!['petId'] : 0,
      'name': _nameController.text,
      'age': int.parse(_ageController.text),
      'price': double.parse(_priceController.text),
      'description': _descriptionController.text,
      'categoryId': isEditing ? widget.pet!['categoryId'] : 1,
      'images': [
        {
          'id': isEditing &&
                  widget.pet!['images'] != null &&
                  widget.pet!['images'].isNotEmpty
              ? widget.pet!['images'][0]['id']
              : 0,
          'petId': isEditing ? widget.pet!['petId'] : 0,
          'url': _imageController.text,
        }
      ],
      'status': _status,
    };

    try {
      String? token = await _getToken();
      final headers = token != null
          ? {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            }
          : {'Content-Type': 'application/json'};

      final response = isEditing
          ? await http.put(
              url,
              headers: headers,
              body: jsonEncode(petData),
            )
          : await http.post(
              url,
              headers: headers,
              body: jsonEncode(petData),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isEditing ? 'Cập nhật thành công!' : 'Thêm mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
          'Không thể lưu thú cưng. Mã lỗi: ${response.statusCode}\nNội dung: ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildImagePreview() {
    if (_imageController.text.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              const Text(
                'Chưa có ảnh',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _imageController.text,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lỗi tải ảnh',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {});
                },
                tooltip: 'Làm mới ảnh',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh sửa thú cưng' : 'Thêm thú cưng mới',
          style: const TextStyle(fontSize: 16),
        ),
        elevation: 1,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      _buildImagePreview(),
                      const SizedBox(height: 24),

                      // Form fields
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thông tin thú cưng',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Name field
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên thú cưng',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.pets),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập tên thú cưng';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Age and Price fields in a row
                              Row(
                                children: [
                                  // Age field
                                  Expanded(
                                    child: TextFormField(
                                      controller: _ageController,
                                      decoration: InputDecoration(
                                        labelText: 'Tuổi',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                        prefixIcon:
                                            const Icon(Icons.calendar_today),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập tuổi';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Tuổi phải là số';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Price field
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      decoration: InputDecoration(
                                        labelText: 'Giá',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                        prefixIcon:
                                            const Icon(Icons.attach_money),
                                        suffixText: 'đ',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập giá';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Giá phải là số';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Description field
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Mô tả',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mô tả';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Image URL field
                              TextFormField(
                                controller: _imageController,
                                decoration: InputDecoration(
                                  labelText: 'URL Ảnh',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.image),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    tooltip: 'Làm mới ảnh',
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập URL ảnh';
                                  }
                                  if (!Uri.tryParse(value)!.isAbsolute) {
                                    return 'URL không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Status dropdown
                              DropdownButtonFormField<String>(
                                value: _status,
                                decoration: InputDecoration(
                                  labelText: 'Trạng thái',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.info_outline),
                                ),
                                items: _statusOptions.map((String status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _status = newValue;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(isEditing ? Icons.save : Icons.add),
                          label: Text(isEditing
                              ? 'Cập nhật thú cưng'
                              : 'Thêm thú cưng mới'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isEditing
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      // Add extra space at the bottom to avoid FAB overlap
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}
