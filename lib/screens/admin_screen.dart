import 'package:flutter/material.dart';
import '../admin/admin_petslist.dart';
import '../admin/admin_productlist.dart';
import '../admin/admin_service.dart';


class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.blue),
            title: const Text('Quản lý thú cưng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPetsList(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.green),
            title: const Text('Quản lý sản phẩm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProductList(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.orange),
            title: const Text('Quản lý dịch vụ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminServiceList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
