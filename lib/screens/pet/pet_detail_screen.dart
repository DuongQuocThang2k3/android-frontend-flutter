import 'package:flutter/material.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pet['name'],
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Hình ảnh sản phẩm
          if (pet['images'] != null && pet['images'].isNotEmpty)
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(pet['images'][0]['url']),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 250,
              color: Colors.grey[200],
              child: const Center(
                child: Text('Không có hình ảnh', style: TextStyle(color: Colors.grey)),
              ),
            ),

          // Thông tin sản phẩm
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet['name'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Giá: ${pet['price']} VND',
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mô tả:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    pet['description'] ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tình trạng: ${pet['status']}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),

          // Nút Mua Ngay
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Hành động khi bấm nút Mua Ngay
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm ${pet['name']} vào giỏ hàng!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'MUA NGAY',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
