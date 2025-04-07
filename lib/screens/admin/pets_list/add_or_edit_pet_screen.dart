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
  String _status = 'Available';
  bool _isSubmitting = false;

  final List<String> _statusOptions = [
    'Available',
    'Adopted',
    'Reserved',
    'Unavailable',
  ];

  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _ageController = TextEditingController(text: pet?.age.toString() ?? '');
    _priceController = TextEditingController(text: pet?.price.toString() ?? '');
    _descriptionController =
        TextEditingController(text: pet?.description ?? '');
    _imageController = TextEditingController(
      text: pet != null && pet.images.isNotEmpty ? pet.images.first : '',
    );
    _status = pet?.status ?? _statusOptions.first;
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
      // <-- sửa ở đây
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
          ),
        );
      } else {
        throw Exception('Server error: ${resp.statusCode}\n${resp.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderPreview(),
      ),
    );
  }

  Widget _placeholderPreview() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          const Center(child: Icon(Icons.pets, size: 48, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa thú cưng' : 'Thêm thú cưng'),
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
                      _buildImagePreview(),
                      const SizedBox(height: 24),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên thú cưng',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 16),

                      // Age & Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Tuổi',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nhập tuổi';
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
                              decoration: const InputDecoration(
                                labelText: 'Giá (đ)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nhập giá';
                                if (int.tryParse(v) == null)
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
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Vui lòng nhập mô tả'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Image URL
                      TextFormField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          labelText: 'URL ảnh',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.image),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => setState(() {}),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Nhập URL ảnh';
                          if (!(Uri.tryParse(v)?.hasAbsolutePath ?? false))
                            return 'URL không hợp lệ';
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          border: OutlineInputBorder(),
                        ),
                        items: _statusOptions
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _status = v);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(isEditing ? Icons.save : Icons.add),
                          label: Text(isEditing ? 'Lưu' : 'Thêm'),
                          onPressed: _submitForm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
