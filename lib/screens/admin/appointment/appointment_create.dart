import 'package:flutter/material.dart';

import '../../../models/appointment.dart';
import 'appointment_service.dart';

class AppointmentCreatePage extends StatefulWidget {
  @override
  _AppointmentCreatePageState createState() => _AppointmentCreatePageState();
}

class _AppointmentCreatePageState extends State<AppointmentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _serviceIdController = TextEditingController();
  final _appointmentDateController = TextEditingController();
  final _statusController = TextEditingController();

  late AppointmentService _appointmentService;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _serviceIdController.dispose();
    _appointmentDateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        final appointment = Appointment(
          userId: _userIdController.text,
          serviceId: int.parse(_serviceIdController.text),
          appointmentDate: _appointmentDateController.text,
          status: _statusController.text,
        );
        await _appointmentService.createAppointment(appointment);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo appointment thành công')),
        );
        Navigator.pop(context);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo appointment')),
        );
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'User ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập User ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _serviceIdController,
                decoration: InputDecoration(labelText: 'Service ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Service ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Service ID phải là số';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _appointmentDateController,
                decoration: InputDecoration(labelText: 'Appointment Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập ngày hẹn';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập trạng thái';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Tạo mới'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
