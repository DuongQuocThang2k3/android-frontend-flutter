import 'dart:convert';

import '../../../models/appointment.dart';
import '../../../services/api_client.dart';

class AppointmentService {
  final ApiClient apiClient;

  AppointmentService({ApiClient? client}) : apiClient = client ?? ApiClient();

  /// Lấy danh sách Appointment
  Future<List<Appointment>> getAppointments() async {
    // Gọi API theo endpoint "Appointment" (không cần "api/")
    final response = await apiClient.get('Appointment');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Không thể lấy danh sách appointment');
    }
  }

  /// Lấy chi tiết Appointment theo ID
  Future<Appointment> getAppointmentById(int id) async {
    // Gọi API theo endpoint "Appointment/{id}"
    final response = await apiClient.get('Appointment/$id');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception('Không thể lấy chi tiết appointment');
    }
  }

  /// Tạo mới Appointment
  Future<Appointment> createAppointment(Appointment appointment) async {
    final response = await apiClient.post(
      'Appointment',
      body: appointment.toJson(),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception('Không thể tạo mới appointment');
    }
  }

  /// Cập nhật Appointment
  Future<Appointment> updateAppointment(Appointment appointment) async {
    if (appointment.appointmentId == null) {
      throw Exception('Yêu cầu AppointmentId để cập nhật');
    }
    final response = await apiClient.put(
      'Appointment/${appointment.appointmentId}',
      body: appointment.toJson(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception('Không thể cập nhật appointment');
    }
  }

  /// Xóa Appointment
  Future<void> deleteAppointment(int id) async {
    final response = await apiClient.delete('Appointment/$id');
    if (response.statusCode != 204) {
      throw Exception('Không thể xóa appointment');
    }
  }
}
