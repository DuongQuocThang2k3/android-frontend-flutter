import 'dart:convert';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../shared_preferences/token_manager.dart';

class Auth {
  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();

  // Phương thức để giải mã token đã lưu thông qua TokenManager
  static Future<Map<String, dynamic>> decodeStoredToken() async {
    return await TokenManager.getDecodedToken();
  }

  // Đăng nhập: gọi AuthService.login (trong đó token đã được lưu qua TokenManager)
  static Future<Map<String, dynamic>> login(String username, String password) async {
    var result = await _authService.login(username, password);
    return result; // Trả về map gồm {success, token, decodedToken, role, message}
  }

  // Đăng ký: gọi API thông qua ApiClient và xử lý kết quả trả về
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String initials,
    required String role,
    required String address,
    required String phoneNumber,
    required String fullName,
  }) async {
    // Tạo body để gửi lên API
    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "initials": initials,
      "role": role,
      "address": address,
      "phoneNumber": phoneNumber,
      "fullName": fullName,
    };

    try {
      // Gọi API đăng ký thông qua ApiClient
      var response = await _apiClient.post('Authenticate/register', body: body);

      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);
        return result;
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại, vui lòng thử lại.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }
}
