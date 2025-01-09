import 'package:geolocator/geolocator.dart';

class LocationService {
  // Lấy vị trí hiện tại
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Trả về null nếu dịch vụ định vị không bật
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Trả về null nếu người dùng từ chối quyền truy cập
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Trả về null nếu quyền truy cập bị từ chối vĩnh viễn
    }

    return await Geolocator.getCurrentPosition(); // Lấy vị trí hiện tại
  }
}
