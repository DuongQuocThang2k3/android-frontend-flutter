import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/config_url.dart';
import '../shared_preferences/token_manager.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? Config_URL.baseUrl;

  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final builtHeaders = await _buildHeaders(headers);
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
    );
  }

  Future<http.Response> post(String endpoint,
      {Map<String, String>? headers,
      dynamic body,
      bool requiresAuth = true}) async {
    final builtHeaders =
        await _buildHeaders(headers, requiresAuth: requiresAuth);
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final builtHeaders = await _buildHeaders(headers);
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final builtHeaders = await _buildHeaders(headers);
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
    );
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? headers,
      {bool requiresAuth = true}) async {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json'
    };

    // Chỉ thêm header Authorization nếu requiresAuth là true
    if (requiresAuth) {
      final token = await TokenManager.getToken();
      if (token != null) {
        defaultHeaders['Authorization'] = 'Bearer $token';
      }
    }

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return defaultHeaders;
  }
}