import 'dart:convert';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../shared_preferences/token_manager.dart';

class Auth {
  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> decodeStoredToken() async {
    return await TokenManager.getDecodedToken();
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    var result = await _authService.login(username, password);
    return result;
  }

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
    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "address": address,
      "phoneNumber": phoneNumber,
      "fullName": fullName,
    };

    print("Request body: $body");

    try {
      var response = await _apiClient.post(
        'Authenticate/register',
        body: body,
        requiresAuth: false,
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return {
          'success': result['Status'] ?? false,
          'message': result['Message'] ?? 'Đăng ký thành công',
        };
      } else {
        var errorResult = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorResult['Message'] ??
              'Đăng ký thất bại, mã lỗi: ${response.statusCode}',
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