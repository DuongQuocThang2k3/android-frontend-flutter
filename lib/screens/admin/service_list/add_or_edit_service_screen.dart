import 'package:flutter/material.dart';

import '../../../services/api_client.dart';

class AddOrEditServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? service;

  const AddOrEditServiceScreen({Key? key, this.service}) : super(key: key);

  @override
  State<AddOrEditServiceScreen> createState() => _AddOrEditServiceScreenState();
}

class _AddOrEditServiceScreenState extends State<AddOrEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  bool _isSubmitting = false;
  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?['name'] ?? '');
    _priceController =
        TextEditingController(text: s?['price']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: s?['description'] ?? '');
    _imageUrlController = TextEditingController(
      text: (s != null && (s['images'] as List).isNotEmpty)
          ? s['images'][0]['url']
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final isEditing = widget.service != null;
    final serviceId = widget.service?['serviceId'];

    final body = {
      if (isEditing) 'serviceId': serviceId,
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()),
      'description': _descriptionController.text.trim(),
      'images': [
        {
          if (isEditing && (widget.service!['images'] as List).isNotEmpty)
            'id': widget.service!['images'][0]['id'],
          'url': _imageUrlController.text.trim(),
          if (isEditing) 'serviceId': serviceId,
        }
      ],
    };

    try {
      final path = isEditing ? 'Service/$serviceId' : 'Service';
      final resp = isEditing
          ? await _api.put(path, body: body)
          : await _api.post(path, body: body);

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
        throw Exception(
            'Failed to save service. Status: ${resp.statusCode}\n${resp.body}');
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
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) {
      return _buildPlaceholder();
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
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
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

  Widget _buildPlaceholder() {
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
          Icon(Icons.spa, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Chưa có ảnh dịch vụ',
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
    final isEditing = widget.service != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isEditing ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ mới',
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
                                'Thông tin dịch vụ',
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
                                  label: 'Tên dịch vụ',
                                  icon: Icons.spa,
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Vui lòng nhập tên dịch vụ'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Price
                              TextFormField(
                                controller: _priceController,
                                decoration: _buildInputDecoration(
                                  label: 'Giá (VND)',
                                  icon: Icons.attach_money,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Vui lòng nhập giá';
                                  if (double.tryParse(v) == null)
                                    return 'Giá phải là số';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Description
                              TextFormField(
                                controller: _descriptionController,
                                decoration: _buildInputDecoration(
                                  label: 'Mô tả dịch vụ',
                                  icon: Icons.description,
                                ),
                                maxLines: 3,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Vui lòng nhập mô tả'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Image URL
                              TextFormField(
                                controller: _imageUrlController,
                                decoration: _buildInputDecoration(
                                  label: 'URL ảnh dịch vụ',
                                  icon: Icons.image,
                                  suffix: IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () => setState(() {}),
                                    tooltip: 'Làm mới ảnh',
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Vui lòng nhập URL ảnh';
                                  if (!(Uri.tryParse(v)?.hasAbsolutePath ??
                                      false)) return 'URL không hợp lệ';
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
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
                            isEditing ? 'Lưu thay đổi' : 'Thêm dịch vụ',
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
