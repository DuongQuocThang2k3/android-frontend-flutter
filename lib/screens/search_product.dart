import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/productPost.dart';

class SearchService {
  final String baseUrl = 'https://foundgreenpen14.conveyor.cloud/api/ProductApi';

  // Tìm kiếm sản phẩm theo ID
  Future<List<productPost>?> searchById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return [productPost.fromJson(data)]; // Trả về một danh sách với sản phẩm tìm thấy
    } else {
      throw Exception('Failed to find pet with ID: $id');
    }
  }

  // Tìm kiếm sản phẩm theo tên
  Future<List<productPost>?> searchByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/search?name=$name'));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}'); // In ra nội dung của response body

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Kiểm tra nếu data là một danh sách
      if (data is List) {
        return data.map((item) => productPost.fromJson(item)).toList();
      }
      // Nếu data là đối tượng có khóa chứa danh sách sản phẩm (ví dụ: "data" hoặc "results")
      else if (data is Map && data['data'] != null) {
        var productList = data['data'] as List;
        return productList.map((item) => productPost.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      // Nếu có thông báo lỗi từ API, in ra để xử lý
      print('Error Response: ${response.body}');
      throw Exception('Failed to find pet with name: $name');
    }
  }
}
