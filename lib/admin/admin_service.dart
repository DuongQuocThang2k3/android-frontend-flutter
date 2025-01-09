import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminServiceList extends StatefulWidget {
  const AdminServiceList({Key? key}) : super(key: key);

  @override
  State<AdminServiceList> createState() => _AdminServiceListState();
}

class _AdminServiceListState extends State<AdminServiceList> {
  List<dynamic> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('https://differentgoldphone43.conveyor.cloud/api/services'));
      if (response.statusCode == 200) {
        setState(() {
          _services = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteService(int serviceId) async {
    try {
      final response = await http.delete(
          Uri.parse('https://differentgoldphone43.conveyor.cloud/api/services/$serviceId'));
      if (response.statusCode == 200) {
        setState(() {
          _services.removeWhere((service) => service['id'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully!')),
        );
      } else {
        throw Exception('Failed to delete service');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addOrEditService({Map<String, dynamic>? service}) async {
    final isEditing = service != null;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditServiceScreen(service: service),
      ),
    );
    if (result == true) {
      _fetchServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách dịch vụ'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return ListTile(
            title: Text(service['name']),
            subtitle: Text('Giá: ${service['price']} VND'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    _addOrEditService(service: service);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteService(service['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditService();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.service != null ? widget.service!['name'] : '');
    _priceController = TextEditingController(
        text: widget.service != null ? widget.service!['price'].toString() : '');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.service != null;
    final url = isEditing
        ? Uri.parse(
        'https://differentgoldphone43.conveyor.cloud/api/services/${widget.service!['id']}')
        : Uri.parse('https://differentgoldphone43.conveyor.cloud/api/services');
    final method = isEditing ? 'PUT' : 'POST';

    try {
      final response = await http.Request(method, url)
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = jsonEncode({
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text),
        });

      final streamedResponse = await response.send();
      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save service');
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
        title: Text(widget.service != null ? 'Sửa dịch vụ' : 'Thêm dịch vụ'),
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
                decoration: const InputDecoration(labelText: 'Tên dịch vụ'),
                validator: (value) =>
                value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá'),
                validator: (value) =>
                value!.isEmpty ? 'Giá không được để trống' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.service != null ? 'Cập nhật' : 'Thêm mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
