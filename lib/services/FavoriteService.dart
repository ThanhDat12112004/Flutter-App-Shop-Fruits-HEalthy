import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fruitshealthy_nhom2/config/config_url.dart';
import 'package:fruitshealthy_nhom2/models/DanhMucYeuThich.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  String get apiUrl => "${Config_URL.baseUrl}api/DanhMucYeuThich";

  // Thêm sản phẩm vào danh mục yêu thích
  Future<bool> addToFavorites(int sanPhamId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để thêm vào yêu thích');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String khachHangId = decodedToken['UserId'];

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "khachHangId": khachHangId,
          "sanPhamId": sanPhamId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Kiểm tra sản phẩm đã được yêu thích chưa
  Future<bool> isFavorite(int sanPhamId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) return false;

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String khachHangId = decodedToken['UserId'];

      final response = await http.get(
        Uri.parse('$apiUrl/KhachHangIdAndSanPhamId/$khachHangId/$sanPhamId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200; // Only return true if status is 200
    } catch (e) {
      return false; // Return false on error
    }
  }

  Future<List<DanhMucYeuThich>> getFavoriteProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('No token found');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String khachHangId = decodedToken['UserId'];

      final response = await http.get(
        Uri.parse('$apiUrl/ByKhachHangId/$khachHangId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => DanhMucYeuThich.fromJson(item)).toList();
      } else {
        throw ('Bạn chưa yêu thích sản phẩm nào');
      }
    } catch (e) {
      throw ('$e');
    }
  }

  // Xóa sản phẩm khỏi danh mục yêu thích
  Future<bool> xoaSanPhamYeuThich(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xóa khỏi yêu thích');
      }

      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
