import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPageScreen extends StatelessWidget {
  const InfoPageScreen({Key? key}) : super(key: key);

  // Thông tin cơ bản
  final String shopName = "Cherry Pet Shop";
  final String welcomeText =
      "Chào mừng quý khách đến với trang thông tin của Cherry Pet Shop!\n\n"
      "Chúng tôi luôn nỗ lực mang đến dịch vụ chăm sóc thú cưng tốt nhất. "
      "Hy vọng bạn sẽ có trải nghiệm tuyệt vời khi ghé thăm Cherry Pet Shop.";

  final String aboutUs =
      "Cherry Pet Shop là nơi bạn tìm thấy tất cả những gì tốt nhất cho thú cưng của mình. "
      "Từ thức ăn chất lượng cao, đồ chơi an toàn đến dịch vụ tư vấn chuyên nghiệp, chúng tôi luôn sẵn sàng phục vụ.";

  // Địa chỉ & link Google Maps
  final String address =
      "10/80c Song Hành Xa Lộ Hà Nội, Phường Tân Phú, Thủ Đức, Hồ Chí Minh, Việt Nam";
  final String googleMapsLink = "https://maps.app.goo.gl/X5Dp41y4YijwrWC7A";

  // Thông tin liên hệ
  final String phoneNumber = "0123 456 789";
  final String email = "contact@cherrypetshop.vn";

  // Link ứng dụng
  final String appLink = "https://www.example.com/cherrypetshopapp";

  // Hàm mở Google Maps
  Future<void> _openGoogleMaps(BuildContext context) async {
    final Uri googleUrl = Uri.parse(googleMapsLink);
    if (!await launchUrl(googleUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể mở Google Maps.")),
      );
    }
  }

  // Hàm mở Link ứng dụng
  Future<void> _openApp(BuildContext context) async {
    final Uri appUri = Uri.parse(appLink);
    if (!await launchUrl(appUri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể mở trang ứng dụng.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: Text(shopName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Body
      body: SingleChildScrollView(
        // Thêm padding dưới để tránh bị che bởi thanh navigation
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần chào mừng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                welcomeText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Khung giới thiệu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Về Cherry Pet Shop",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aboutUs,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            // Khung thông tin chính
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon đánh dấu địa chỉ
                  Center(
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Địa chỉ
                  Center(
                    child: Text(
                      address,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mở Google Maps khi nhấn
                  Center(
                    child: GestureDetector(
                      onTap: () => _openGoogleMaps(context),
                      child: Text(
                        "Nhấn để xem trên Google Maps",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 8),

                  // Số điện thoại
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        phoneNumber,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.red[300]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () => _openApp(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Trải nghiệm đặt lịch, nhận thông báo và ưu đãi độc quyền trên ứng dụng di động của Cherry Pet Shop."
                  "\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
