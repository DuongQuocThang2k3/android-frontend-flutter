import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/postFacebook.dart';

class DeletePostScreen extends StatelessWidget {
  final postFacebook post; // Nhận bài đăng cần xóa

  const DeletePostScreen({super.key, required this.post});

  Future<void> _deletePost(BuildContext context) async {
    final url =
        'https://foundgreenpen14.conveyor.cloud/api/PostApi/${post.id}';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Navigator.pop(context, true); // Quay về màn hình chính
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa bài đăng thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể xóa bài đăng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xóa Bài Đăng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa bài đăng "${post.ten}" không?',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _deletePost(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Xóa'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
