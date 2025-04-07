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
    print("GET Request Headers: $builtHeaders");
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
    final String bodyString = jsonEncode(body);
    print("POST Request Headers: $builtHeaders");
    print("POST Request Body: $bodyString");
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
      body: bodyString,
    );
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final builtHeaders = await _buildHeaders(headers);
    final String bodyString = jsonEncode(body);
    print("PUT Request Headers: $builtHeaders");
    print("PUT Request Body: $bodyString");
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
      body: bodyString,
    );
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final builtHeaders = await _buildHeaders(headers);
    print("DELETE Request Headers: $builtHeaders");
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: builtHeaders,
    );
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? headers,
      {bool requiresAuth = true}) async {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenManager.getToken();
      print("Token from TokenManager: $token");
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
