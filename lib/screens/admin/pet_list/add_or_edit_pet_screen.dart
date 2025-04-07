import 'package:flutter/material.dart';

import '../../../models/petItem.dart';
import '../../../services/api_client.dart';

class AddOrEditPetScreen extends StatefulWidget {
  final PetItem? pet;

  const AddOrEditPetScreen({Key? key, this.pet}) : super(key: key);

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
  late List<String> _statusOptions;
  late String _status;
  bool _isSubmitting = false;

  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();

    // Khởi tạo các option
    _statusOptions = [
      'Available',
      'Adopted',
      'Reserved',
      'Unavailable',
    ];

    // Nếu pet có status không nằm trong options, thêm vào đầu
    final petStatus = widget.pet?.status;
    if (petStatus != null && !_statusOptions.contains(petStatus)) {
      _statusOptions.insert(0, petStatus);
    }

    // Chọn giá trị hiện tại
    _status = petStatus ?? _statusOptions.first;

    // Controllers
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _ageController = TextEditingController(text: pet?.age.toString() ?? '');
    _priceController = TextEditingController(text: pet?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: pet?.description ?? '');
    _imageController = TextEditingController(
      text: pet != null && pet.images.isNotEmpty ? pet.images.first : '',
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final isEditing = widget.pet != null;
    final petId = widget.pet?.petId ?? 0;
    final categoryId = widget.pet?.categoryId ?? 1;

    final newPet = PetItem(
      petId: petId,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      description: _descriptionController.text.trim(),
      categoryId: categoryId,
      images: _imageController.text.trim().isNotEmpty
          ? [_imageController.text.trim()]
          : [],
      status: _status,
    );

    try {
      final path = isEditing ? 'Pet/$petId' : 'Pet';
      final resp = isEditing
          ? await _api.put(path, body: newPet.toJson())
          : await _api.post(path, body: newPet.toJson());

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isEditing ? 'Cập nhật thành công!' : 'Thêm mới thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        throw Exception('Server error: ${resp.statusCode}\n${resp.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildImagePreview() {
    final url = _imageController.text.trim();
    if (url.isEmpty) {
      return _placeholderPreview();
    }
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderPreview(),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => setState(() {}),
                  tooltip: 'Làm mới ảnh',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Chưa có ảnh',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isEditing ? 'Chỉnh sửa thú cưng' : 'Thêm thú cưng mới',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    isEditing ? 'Đang cập nhật...' : 'Đang thêm mới...',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      _buildImagePreview(),
                      const SizedBox(height: 24),

                      // Form fields in a card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin thú cưng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration(
                            label: 'Tên thú cưng',
                            icon: Icons.pets,
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty
                              ? 'Vui lòng nhập tên'
                              : null,
                        ),
                        const SizedBox(height: 16),

                              // Age & Price
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _ageController,
                                      decoration: _buildInputDecoration(
                                        label: 'Tuổi',
                                        icon: Icons.calendar_today,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Nhập tuổi';
                                        if (int.tryParse(v) == null)
                                          return 'Tuổi phải là số';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      decoration: _buildInputDecoration(
                                        label: 'Giá (đ)',
                                        icon: Icons.attach_money,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Nhập giá';
                                        if (double.tryParse(v) == null)
                                          return 'Giá phải là số';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _buildInputDecoration(
                            label: 'Mô tả',
                            icon: Icons.description,
                          ),
                          maxLines: 3,
                          validator: (v) =>
                          v == null || v.isEmpty
                              ? 'Vui lòng nhập mô tả'
                              : null,
                        ),
                        const SizedBox(height: 16),

                              // Image URL
                              TextFormField(
                                controller: _imageController,
                                decoration: _buildInputDecoration(
                                  label: 'URL ảnh',
                                  icon: Icons.image,
                                  suffix: IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () => setState(() {}),
                                    tooltip: 'Làm mới ảnh',
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Nhập URL ảnh';
                                  if (!(Uri.tryParse(v)?.hasAbsolutePath ??
                                      false)) return 'URL không hợp lệ';
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              // Status
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: _buildInputDecoration(
                            label: 'Trạng thái',
                            icon: Icons.info_outline,
                          ),
                          items: _statusOptions.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
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
                        height: 54,
                        child: ElevatedButton.icon(
                          icon: Icon(isEditing ? Icons.save : Icons.add),
                          label: Text(
                            isEditing ? 'Lưu thay đổi' : 'Thêm thú cưng',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isEditing ? Colors.blue : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _submitForm,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}