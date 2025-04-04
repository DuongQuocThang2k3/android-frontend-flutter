import 'package:flutter/material.dart';

import '../admin/admin_petslist.dart';
import '../admin/admin_productlist.dart';
import '../admin/admin_service.dart';
import 'admin_order_list.dart';
import 'admin_roleclaim.dart';
import 'admin_user_list.dart';
import 'user_role.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Định nghĩa các mục quản lý
    final adminMenuItems = [
      {
        'title': 'Quản lý thú cưng',
        'icon': Icons.pets,
        'color': Colors.blue.shade700,
        'route': const AdminPetsList(),
      },
      {
        'title': 'Quản lý sản phẩm',
        'icon': Icons.shopping_cart,
        'color': Colors.green.shade600,
        'route': const AdminProductList(),
      },
      {
        'title': 'Quản lý dịch vụ',
        'icon': Icons.build,
        'color': Colors.orange.shade600,
        'route': const AdminServiceList(),
      },
      {
        'title': 'Quản lý người dùng',
        'icon': Icons.people,
        'color': Colors.purple.shade600,
        'route': const AdminUserList(),
      },
      {
        'title': 'Quản lý đơn hàng',
        'icon': Icons.list_alt,
        'color': Colors.blueAccent.shade400,
        'route': const AdminOrderList(),
      },
      {
        'title': 'QL Role Claim',
        'icon': Icons.security,
        'color': Colors.red.shade600,
        'route': const AdminRolePage(),
      },
      {
        'title': 'QL Role người dùng',
        'icon': Icons.person_add,
        'color': Colors.teal.shade600,
        'route': const UserRolePage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey.shade800),
        titleTextStyle: TextStyle(color: Colors.grey.shade800),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  'Chức năng quản trị',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              // Grid layout cho các mục quản lý
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5, // Tăng tỷ lệ để tránh tràn
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: adminMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = adminMenuItems[index];
                    return _buildAdminMenuItem(
                      context,
                      title: item['title'] as String,
                      icon: item['icon'] as IconData,
                      color: item['color'] as Color,
                      route: item['route'] as Widget,
                      index: index, // Thêm index để tạo tag duy nhất
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Loại bỏ FloatingActionButton để tránh lỗi Hero tag
    );
  }

  Widget _buildAdminMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget route,
    required int index, // Thêm tham số index
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            // Thêm mainAxisSize: MainAxisSize.min để tránh tràn
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6), // Giảm khoảng cách
              Flexible(
                // Bọc Text trong Flexible để tránh tràn
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}