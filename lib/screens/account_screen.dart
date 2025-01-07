import 'package:flutter/material.dart';
import 'edit_account_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Dữ liệu người dùng
  String avatarUrl = 'https://i.redd.it/vgzby6zrlg8b1.jpg';
  String name = 'Hà Phước Lộc';
  String email = 'haphuoclocbaclieu@gmail.com';
  String phone = '0948447004';
  String address = 'Tp.Thủ Đức, Việt Nam';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl), // Hiển thị ảnh đại diện
            ),
            const SizedBox(height: 10),
            Text(
              name, // Hiển thị tên người dùng
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blueAccent),
              title: const Text('Email'),
              subtitle: Text(email), // Hiển thị email
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blueAccent),
              title: const Text('Số điện thoại'),
              subtitle: Text(phone), // Hiển thị số điện thoại
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blueAccent),
              title: const Text('Địa chỉ'),
              subtitle: Text(address), // Hiển thị địa chỉ
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                // Chuyển đến màn hình chỉnh sửa và nhận kết quả
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAccountScreen(
                      avatarUrl: avatarUrl,
                      name: name,
                      email: email,
                      phone: phone,
                      address: address,
                    ),
                  ),
                );

                if (result != null) {
                  // Cập nhật dữ liệu nếu có thay đổi
                  setState(() {
                    avatarUrl = result['avatarUrl'];
                    name = result['name'];
                    email = result['email'];
                    phone = result['phone'];
                    address = result['address'];
                  });
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Chỉnh sửa thông tin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
