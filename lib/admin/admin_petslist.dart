import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPetsList extends StatefulWidget {
  const AdminPetsList({Key? key}) : super(key: key);

  @override
  State<AdminPetsList> createState() => _AdminPetsListState();
}

class _AdminPetsListState extends State<AdminPetsList> {
  List<dynamic> _pets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://greatmintwave90.conveyor.cloud/api/Pet'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _pets = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load pets');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deletePet(int petId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://greatmintwave90.conveyor.cloud/api/Pet/$petId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _pets.removeWhere((pet) => pet['petId'] == petId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet deleted successfully!')),
        );
      } else {
        throw Exception('Failed to delete pet');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thú cưng'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _pets.length,
        itemBuilder: (context, index) {
          final pet = _pets[index];
          return ListTile(
            title: Text(pet['name']),
            subtitle: Text('Mô tả: ${pet['description']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    _addOrEditPet(pet: pet);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deletePet(pet['petId']);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditPet();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddOrEditPetScreen extends StatefulWidget {
  final Map<String, dynamic>? pet;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?['name'] ?? '');
    _ageController = TextEditingController(text: widget.pet?['age']?.toString() ?? '');
    _priceController = TextEditingController(text: widget.pet?['price']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.pet?['description'] ?? '');
    _imageController = TextEditingController(
      text: widget.pet?['images']?.isNotEmpty == true
          ? widget.pet!['images'][0]['imageUrl']
          : '',
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.pet != null;
    final url = isEditing
        ? Uri.parse(
        'https://greatmintwave90.conveyor.cloud/api/Pet/${widget.pet!['petId']}')
        : Uri.parse('https://greatmintwave90.conveyor.cloud/api/Pet');

    final petData = {
      'name': _nameController.text,
      'age': int.parse(_ageController.text),
      'price': double.parse(_priceController.text),
      'description': _descriptionController.text,
      'images': [
        {'imageUrl': _imageController.text}
      ],
      'status': 1, // Default status
      'categoryId': 1 // Default category ID
    };

    try {
      final response = isEditing
          ? await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(petData),
      )
          : await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(petData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save pet: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet != null ? 'Sửa thú cưng' : 'Thêm thú cưng'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thú cưng'),
                validator: (value) =>
                value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Tuổi'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Tuổi không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Giá không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                validator: (value) =>
                value!.isEmpty ? 'Mô tả không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'URL Ảnh'),
                validator: (value) =>
                value!.isEmpty ? 'URL ảnh không được để trống' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.pet != null ? 'Cập nhật' : 'Thêm mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
