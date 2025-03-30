import 'package:fruitshealthy_nhom2/models/GioHang.dart';
import 'package:fruitshealthy_nhom2/models/SanPham.dart';
import 'package:fruitshealthy_nhom2/models/DonHang.dart';
import 'package:fruitshealthy_nhom2/models/ChiTietDonHang.dart';
import 'package:fruitshealthy_nhom2/services/DonHangService%20.dart';
import 'package:fruitshealthy_nhom2/services/GioHang_Service.dart';
import 'package:fruitshealthy_nhom2/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final DonHangService _donHangService = DonHangService();
  final TextEditingController _addressController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  String _error = '';
  int _totalAmount = 0;


  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _checkName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Vui lòng đăng nhập để thêm vào yêu thích');
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    _addressController.text = decodedToken['DiaChi'];
  }

  Future<void> _loadCart() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final cartItems = await _cartService.getCartItems();
      _cartItems = [];

      for (var cartItem in cartItems) {
        if (cartItem.sanPhamId != null) {
          try {
            final product =
                await _productService.getProductById(cartItem.sanPhamId!);
            _cartItems.add({
              'cart': cartItem,
              'product': product,
            });
          } catch (e) {
            print('Error loading product ${cartItem.sanPhamId}: $e');
          }
        }
      }
      _cartItems.sort((a, b) {
        final timeA = (a['cart'] as GioHang).gioHangId ?? 1;
        final timeB = (b['cart'] as GioHang).gioHangId ?? 1;
        return timeB.compareTo(timeA);
      });

      setState(() {
        _isLoading = false;
        _calculateTotal();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCart() async {
    try {
      for (var item in _cartItems) {
        final cart = item['cart'] as GioHang;
        await _cartService.removeFromCart(cart.gioHangId!);
      }

      if (mounted) {
        setState(() {
          _cartItems = [];
          _totalAmount = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa giỏ hàng: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateQuantity(GioHang cart, int newQuantity) async {
    if (newQuantity < 1) return;
    try {
      final success = await _cartService.updateQuantity(cart, newQuantity);
      if (success) {
        await _loadCart();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật số lượng')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeItem(GioHang cart) async {
    try {
      final success = await _cartService.removeFromCart(cart.gioHangId!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng')),
        );
        await _loadCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _createOrder() async {
    try {
      if (_addressController.text.trim().isEmpty) {
        throw Exception('Vui lòng nhập địa chỉ giao hàng');
      }

      // Create order with address
      final donHang = DonHang(
        donHangId: null,
        khachHangId: "current_user_id", // Replace with actual user ID
        ngayDat: DateTime.now(),
        tongTien: _totalAmount,
        diaChi: _addressController.text.trim(),
        trangThai: null,
      );

      final orderId = await _donHangService.createOrder(donHang);

      // Create order details
      for (var item in _cartItems) {
        final cart = item['cart'] as GioHang;
        final product = item['product'] as SanPham;

        final chiTietDonHang = ChiTietDonHang(
            chiTietDonHangId: null,
            donHangId: orderId,
            sanPhamId: product.sanPhamId,
            soLuong: cart.soLuong,
            giaBan: product.giaBan);

        await _donHangService.createOrderDetail(chiTietDonHang);
      }

      // Clear cart and address
      await _clearCart();
      _addressController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Đặt hàng thành công!',
            style: TextStyle(color: Colors.green),
          )),
        );
        await _loadCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  void _showOrderDialog() {
    _checkName();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin đặt hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng',
                  hintText: 'Nhập địa chỉ giao hàng của bạn',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Tổng tiền: ${currencyFormat.format(_totalAmount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Đặt hàng'),
              onPressed: () {
                Navigator.of(context).pop();
                _createOrder();
              },
            ),
          ],
        );
      },
    );
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0, (sum, item) {
      final product = item['product'] as SanPham;
      final cart = item['cart'] as GioHang;
      return sum + (product.giaBan ?? 0) * (cart.soLuong ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://raw.githubusercontent.com/ThanhDat12112004/images_fruits/refs/heads/main/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              'Giỏ hàng',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentColor,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child:
                      Text(_error, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      child: _cartItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart_outlined,
                                      size: 72, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text('Giỏ hàng trống',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                final cart =
                                    _cartItems[index]['cart'] as GioHang;
                                final product =
                                    _cartItems[index]['product'] as SanPham;

                                return Dismissible(
                                  key: Key(cart.gioHangId.toString()),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.red,
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  onDismissed: (_) => _removeItem(cart),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              product.anhSanPham ?? '',
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                width: 90,
                                                height: 90,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.image),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.tenSanPham ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  currencyFormat.format(
                                                      product.giaBan ?? 0),
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey[300]!),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.remove,
                                                                size: 18),
                                                            onPressed: () =>
                                                                _updateQuantity(
                                                                    cart,
                                                                    (cart.soLuong ??
                                                                            0) -
                                                                        1),
                                                          ),
                                                          Text(
                                                            '${cart.soLuong ?? 0}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.add,
                                                                size: 18),
                                                            onPressed: () =>
                                                                _updateQuantity(
                                                                    cart,
                                                                    (cart.soLuong ??
                                                                            0) +
                                                                        1),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () =>
                                                          _removeItem(cart),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (_cartItems.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Tổng tiền',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(_totalAmount),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _showOrderDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Đặt hàng',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
