import 'package:flutter/material.dart';
import '../admin/admin_petslist.dart';
import '../admin/admin_productlist.dart';
import '../admin/admin_service.dart';
import 'admin_order_list.dart';
import 'admin_user_list.dart'; // Import UserList
import 'admin_role.dart'; // Import file AdminRolePage
import 'user_role.dart'; // Import file UserRolePage

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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.purple),
            title: const Text('Quản lý người dùng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUserList(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.blueAccent),
            title: const Text('Quản lý Danh sách Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminOrderList(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.red),
            title: const Text('Quản lý quyền (Claim)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  AdminRolePage(),
                ),
              );
            },
          ),
          const Divider(),
          // Mục Quản lý quyền người dùng (User Role)
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blueAccent),
            title: const Text('Quản lý quyền người dùng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserRolePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
