import 'dart:convert';
import 'package:fruitshealthy_nhom2/models/GioHang.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Vui lòng đăng nhập để thêm vào yêu thích');
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['UserId'];
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}api/GioHang'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'khachHangId': userId,
          'sanPhamId': productId,
          'soLuong': quantity,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<List<GioHang>> getCartItems() async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/GioHang/ByKhachHangId/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => GioHang.fromJson(item)).toList();
      }
      throw ('Giỏ hàng của bạn đang trống!');
    } catch (e) {
      throw ('$e');
    }
  }

  Future<bool> updateQuantity(GioHang cart, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('${dotenv.env['BASE_URL']}api/GioHang/${cart.gioHangId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'gioHangId': cart.gioHangId,
          'khachHangId': cart.khachHangId,
          'sanPhamId': cart.sanPhamId,
          'soLuong': quantity,
          'thoiGian': DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(cart.thoiGian.toString()))
        }),
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  Future<bool> removeFromCart(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}api/GioHang/$cartId'),
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }
}
