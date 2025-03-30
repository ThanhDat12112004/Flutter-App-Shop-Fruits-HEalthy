// product_service.dart
import 'dart:convert';
import 'package:fruitshealthy_nhom2/config/config_url.dart';
import 'package:fruitshealthy_nhom2/models/SanPham.dart';
import 'package:http/http.dart' as http;

class ProductService {
  String get apiUrl => "${Config_URL.baseUrl}api/ProductApi";

  Future<SanPham> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$id'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return SanPham.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
}

