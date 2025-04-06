import 'package:flutter/material.dart';

import '../../models/pet_service_model.dart';
import '../../shared_preferences/token_manager.dart';
import 'appointment_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final PetService service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    // Lấy userId từ TokenManager (tự decode token hoặc session) :contentReference[oaicite:0]{index=0}
    final id = await TokenManager.getUserId();
    debugPrint("User ID được lấy: $id");
    setState(() {
      _userId = id;
    });

    // Nếu bạn đã lưu toàn bộ UserModel khi login, có thể dùng:
    // final user = UserModel.currentUser;
    // setState(() { _userId = user?.id; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service.name,
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh dịch vụ
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.service.images.isNotEmpty
                        ? widget.service.images[0].url
                        : 'https://via.placeholder.com/250x250',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tên dịch vụ
            Text(
              widget.service.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Giá tiền
            Text(
              'Giá: ${widget.service.price} VND',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 12),
            // Mô tả dịch vụ
            const Text(
              'Mô tả:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.service.description,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            // Nút "Đặt lịch"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _userId != null
                    ? () {
                        debugPrint("User ID hợp lệ: $_userId");
                        Navigator.push(
                    context,
                    MaterialPageRoute(
                            builder: (_) => AppointmentScreen(
                              service: widget.service,
                        userId: _userId!,
                      ),
                    ),
                  );
                }
                    : null, // Vô hiệu hóa nếu userId chưa được tải
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Đặt lịch",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
