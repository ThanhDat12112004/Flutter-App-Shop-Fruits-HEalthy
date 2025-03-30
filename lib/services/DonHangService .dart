import 'dart:convert';
import 'package:fruitshealthy_nhom2/models/ChiTietDonHang.dart';
import 'package:fruitshealthy_nhom2/models/DonHang.dart';
import 'package:fruitshealthy_nhom2/models/User.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class DonHangService {
  Future<void> deleteOrder(int donHangId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xóa đơn hàng');
      }

      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}api/donhangapi/$donHangId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi xóa đơn hàng: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi xóa đơn hàng: $e');
    }
  }

  Future<void> updateOrderAddress(DonHang donhang, String newAddress) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để cập nhật địa chỉ');
      }

      final response = await http.put(
        Uri.parse(
            '${dotenv.env['BASE_URL']}api/donhangapi/${donhang.donHangId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "donHangId": donhang.donHangId,
          "khachHangId": donhang.khachHangId,
          "diaChi": newAddress,
          "ngayDat": DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(donhang.ngayDat.toString())),
          "tongTien": donhang.tongTien,
          "trangThai": donhang.trangThai,
        }),
      );

      if (response.statusCode != 204) {
        throw Exception('Lỗi cập nhật địa chỉ: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật địa chỉ: $e');
    }
  }

  Future<void> updateOrderStatus(DonHang donhang, String newStatus) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để cập nhật địa chỉ');
      }

      final response = await http.put(
        Uri.parse(
            '${dotenv.env['BASE_URL']}api/donhangapi/${donhang.donHangId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "donHangId": donhang.donHangId,
          "khachHangId": donhang.khachHangId,
          "diaChi": donhang.diaChi,
          "ngayDat": DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(donhang.ngayDat.toString())),
          "tongTien": donhang.tongTien,
          "trangThai": newStatus,
        }),
      );

      if (response.statusCode != 204) {
        throw Exception('Lỗi cập nhật trạng thái: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái: $e');
    }
  }

  Future<int> createOrder(DonHang donHang) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để đặt hàng');
      }

      // Get user ID from token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['UserId'];

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}api/DonHangApi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'khachHangId': userId,
          'tongTien': donHang.tongTien,
          'diaChi': donHang.diaChi, // Include delivery address
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['donHangId'];
      }

      throw Exception('Lỗi tạo đơn hàng: ${response.body}');
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  Future<void> createOrderDetail(ChiTietDonHang chiTietDonHang) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để tạo chi tiết đơn hàng');
      }

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}api/ChiTietDonHangApi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'donHangId': chiTietDonHang.donHangId,
          'sanPhamId': chiTietDonHang.sanPhamId,
          'soLuong': chiTietDonHang.soLuong,
          'giaBan': chiTietDonHang.giaBan
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Lỗi tạo chi tiết đơn hàng: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi tạo chi tiết đơn hàng: $e');
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xem thông tin người dùng');
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/Authenticate/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception('Dữ liệu phản hồi không hợp lệ');
        }
      } else {
        throw Exception('Lỗi tải thông tin người dùng: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi tải thông tin người dùng: $e');
    }
  }

  Future<List<DonHang>> getOrders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xem đơn hàng');
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/donhangapi'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DonHang.fromJson(json)).toList();
      }

      throw Exception('Lỗi tải đơn hàng: ${response.body}');
    } catch (e) {
      throw Exception('Lỗi tải đơn hàng: $e');
    }
  }

  Future<List<DonHang>> getOrdersByUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xem đơn hàng');
      }
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['UserId'];

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/donhangapi/khachhang/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DonHang.fromJson(json)).toList();
      }

      throw ('Bạn chưa có đơn hàng nào!');
    } catch (e) {
      throw ('$e');
    }
  }

  Future<List<ChiTietDonHang>> getOrderDetails(int donHangId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để xem chi tiết đơn hàng');
      }

      final response = await http.get(
        Uri.parse(
            '${dotenv.env['BASE_URL']}api/chitietdonhangapi/donhang/$donHangId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChiTietDonHang.fromJson(json)).toList();
      }

      throw Exception('Lỗi tải chi tiết đơn hàng: ${response.body}');
    } catch (e) {
      throw Exception('Lỗi tải chi tiết đơn hàng: $e');
    }
  }
}
