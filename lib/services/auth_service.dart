import 'dart:convert';

import '../services/api_client.dart';
import '../shared_preferences/token_manager.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Endpoint đăng nhập (baseUrl được cấu hình trong ApiClient)
  String get apiUrl => "Authenticate/login";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Gọi API đăng nhập thông qua ApiClient
      final response = await _apiClient.post(apiUrl, body: {
        "username": username,
        "password": password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool status = data['status'];
        if (!status) {
          return {"success": false, "message": data['message']};
        }

        // Lấy token trả về từ API
        String token = data['token'];

        // Lưu token vào SharedPreferences qua TokenManager
        await TokenManager.saveToken(token);

        // Lấy token đã được giải mã thông qua TokenManager
        Map<String, dynamic> decodedToken =
            await TokenManager.getDecodedToken();

        return {
          "success": true,
          "token": token,
          "decodedToken": decodedToken,
          "role": decodedToken['role'],
        };
      } else {
        return {"success": false, "message": "Failed to login: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
