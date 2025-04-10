import 'package:flutter/material.dart';

import '../../../models/appointment.dart';
import 'appointment_service.dart';

class AppointmentDetailPage extends StatelessWidget {
  final int id;

  const AppointmentDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppointmentService appointmentService = AppointmentService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Appointment'),
      ),
      body: FutureBuilder<Appointment>(
        future: appointmentService.getAppointmentById(id),
        builder: (context, snapshot) {
          // Hiển thị loading khi đang chờ dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Nếu có lỗi, hiển thị thông báo lỗi
          else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          // Nếu không có dữ liệu trả về
          else if (!snapshot.hasData) {
            return Center(child: Text('Không tìm thấy appointment'));
          }
          // Khi có dữ liệu trả về, hiển thị thông tin chi tiết
          final appointment = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${appointment.appointmentId}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('User ID: ${appointment.userId}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Service ID: ${appointment.serviceId}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Ngày hẹn: ${appointment.appointmentDate}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Trạng thái: ${appointment.status}', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
