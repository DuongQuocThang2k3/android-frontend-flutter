class Appointment {
  final int? appointmentId; // Sử dụng null khi tạo mới
  final String userId;
  final int serviceId;
  final String appointmentDate;
  final String status;

  Appointment({
    this.appointmentId,
    required this.userId,
    required this.serviceId,
    required this.appointmentDate,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      userId: json['userId'],
      serviceId: json['serviceId'],
      appointmentDate: json['appointmentDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      "userId": userId,
      "serviceId": serviceId,
      "appointmentDate": appointmentDate,
      "status": status,
    };
    if (appointmentId != null) {
      data['appointmentId'] = appointmentId as Object;
    }
    return data;
  }
}
