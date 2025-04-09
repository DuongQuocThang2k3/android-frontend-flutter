import 'dart:convert';

import '../../../models/product_model.dart';
import '../../../shared_preferences/token_manager.dart';

class CacheProduct {
  static const String cacheKey = 'productsData';

  /// Lưu danh sách sản phẩm (Product) vào cache dưới dạng JSON.
  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await TokenManager.getInstance();
    // Chuyển đổi danh sách Product thành List<Map<String, dynamic>> rồi encode thành JSON
    final productsJson =
        jsonEncode(products.map((product) => product.toJson()).toList());
    await prefs.setString(cacheKey, productsJson);
  }

  /// Lấy danh sách sản phẩm từ cache.
  /// Trả về danh sách các đối tượng Product. Nếu chưa có dữ liệu, trả về danh sách rỗng.
  static Future<List<Product>> loadProducts() async {
    final prefs = await TokenManager.getInstance();
    final productsData = prefs.getString(cacheKey);
    if (productsData != null) {
      final List<dynamic> decoded = jsonDecode(productsData);
      return decoded.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  /// Xóa dữ liệu cache của danh sách sản phẩm.
  static Future<void> clearCache() async {
    final prefs = await TokenManager.getInstance();
    await prefs.remove(cacheKey);
  }
}
