import 'package:flutter/material.dart';

import '../../../models/appointment.dart';
import 'appointment_create.dart';
import 'appointment_detail.dart';
import 'appointment_edit.dart';
import 'appointment_service.dart';

class AppointmentListPage extends StatefulWidget {
  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  late AppointmentService _appointmentService;
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final appointments = await _appointmentService.getAppointments();
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách appointment')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _deleteAppointment(int id) async {
    try {
      await _appointmentService.deleteAppointment(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment đã được xóa')),
      );
      _loadAppointments();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa appointment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Appointment'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAppointments,
        child: ListView.builder(
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            final appointment = _appointments[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text('Appointment ${appointment.appointmentId ?? ""}'),
                subtitle: Text(
                  'Date: ${appointment.appointmentDate}\nStatus: ${appointment.status}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Xem chi tiết
                    IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {
                        if (appointment.appointmentId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppointmentDetailPage(
                                  id: appointment.appointmentId!),
                            ),
                          );
                        }
                      },
                    ),
                    // Chỉnh sửa
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        if (appointment.appointmentId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppointmentEditPage(
                                  appointment: appointment),
                            ),
                          ).then((_) => _loadAppointments());
                        }
                      },
                    ),
                    // Xóa
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        if (appointment.appointmentId != null) {
                          _deleteAppointment(appointment.appointmentId!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AppointmentCreatePage()),
          ).then((_) => _loadAppointments());
        },
      ),
    );
  }
}
