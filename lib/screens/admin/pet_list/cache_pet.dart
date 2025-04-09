import 'dart:convert';

import '../../../models/petItem.dart';
import '../../../shared_preferences/token_manager.dart';

class CachePet {
  static const String cacheKey = 'petsData';

  /// Lưu danh sách thú cưng vào cache dưới dạng JSON.
  static Future<void> savePets(List<PetItem> petList) async {
    final prefs = await TokenManager.getInstance();
    final petsJson = jsonEncode(
      petList.map((pet) => pet.toJson()).toList(),
    );
    await prefs.setString(cacheKey, petsJson);
  }

  /// Lấy danh sách thú cưng từ cache.
  /// Nếu chưa có dữ liệu, trả về danh sách rỗng.
  static Future<List<PetItem>> loadPets() async {
    final prefs = await TokenManager.getInstance();
    final petsData = prefs.getString(cacheKey);
    if (petsData != null) {
      final List<dynamic> decoded = jsonDecode(petsData);
      return decoded.map((e) => PetItem.fromJson(e)).toList();
    }
    return [];
  }

  /// Xóa cache của danh sách thú cưng.
  static Future<void> clearCache() async {
    final prefs = await TokenManager.getInstance();
    await prefs.remove(cacheKey);
  }
}
