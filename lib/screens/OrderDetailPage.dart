import 'package:fruitshealthy_nhom2/models/ChiTietDonHang.dart';
import 'package:fruitshealthy_nhom2/models/DonHang.dart';
import 'package:fruitshealthy_nhom2/models/SanPham.dart';
import 'package:fruitshealthy_nhom2/models/User.dart';
import 'package:fruitshealthy_nhom2/services/DonHangService%20.dart';
import 'package:fruitshealthy_nhom2/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';
import 'package:intl/intl.dart';

// Define OrderItemWithProduct class at the top level
class OrderItemWithProduct {
  final ChiTietDonHang detail;
  final SanPham product;

  OrderItemWithProduct({
    required this.detail,
    required this.product,
  });
}

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final DonHangService _orderService = DonHangService();
  final ProductService _productService = ProductService();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  DonHang? _order;
  User? _user;
  List<OrderItemWithProduct> _orderItems = [];
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _userData;
  final TextEditingController _addressController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    //  _loadUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showUpdateAddressDialog() async {
    _addressController.text = _order?.diaChi ?? '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật địa chỉ giao hàng'),
        content: TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ mới',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (_addressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập địa chỉ mới')),
                );
                return;
              }
              Navigator.of(context).pop();
              await _updateAddress(_order!, _addressController.text.trim());
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAddress(DonHang order, String newAddress) async {
    try {
      await _orderService.updateOrderAddress(order, newAddress);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật địa chỉ thành công')),
      );

      await _loadOrderDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật địa chỉ: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateStatus(DonHang order, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(order, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái thành công')),
      );

      await _loadOrderDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật trạng thái: ${e.toString()}')),
      );
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateStatus(_order!, "Đã hủy");
            },
            child: const Text('Có', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Future<void> _deleteOrder() async {
  //   try {
  //     if (_order?.donHangId == null) return;

  //     await _orderService.deleteOrder(_order!.donHangId!);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Đã xóa đơn hàng thành công')),
  //     );

  //     // Navigate back to order list
  //     if (mounted) {
  //       Navigator.of(context).pop();
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Lỗi xóa đơn hàng: ${e.toString()}')),
  //     );
  //   }
  // }

  // Future<void> _loadUserData() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('jwt_token');

  //     if (token != null) {
  //       Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //       setState(() {
  //         _userData = {
  //           'UserId': decodedToken['UserId'],
  //           'TenKhachHang': decodedToken['TenKhachHang'],
  //           'SoDienThoai': decodedToken['SoDienThoai'],
  //         };
  //       });
  //     }
  //   } catch (e) {
  //     print('Error loading user data: $e');
  //   }
  // }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Fetch order and details
      final orders = await _orderService.getOrders();
      final order = orders.firstWhere(
        (order) => order.donHangId == widget.orderId,
        orElse: () => throw Exception('Không tìm thấy đơn hàng'),
      );
      final details = await _orderService.getOrderDetails(widget.orderId);
      final user = await _orderService.getUserById(order.khachHangId!);

      // Fetch product details for each order item
      final List<OrderItemWithProduct> orderItems = [];
      for (var detail in details) {
        try {
          final product =
              await _productService.getProductById(detail.sanPhamId ?? 0);
          orderItems
              .add(OrderItemWithProduct(detail: detail, product: product));
        } catch (e) {
          print('Error fetching product ${detail.sanPhamId}: $e');
          // Add item with null product if fetch fails
        }
      }

      setState(() {
        _order = order;
        _user = user;
        _orderItems = orderItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildUserInfoSection() {
    bool isPending = _order?.trangThai?.toString() == 'Chưa xử lý';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin khách hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPending)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_location),
                      onPressed: _showUpdateAddressDialog,
                      tooltip: 'Cập nhật địa chỉ',
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _showDeleteConfirmDialog,
                      tooltip: 'Hủy đơn hàng',
                      color: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Tên khách hàng',
            _user?.tenKhachHang ?? 'N/A',
          ),
          _buildInfoRow(
            'Số điện thoại',
            _user?.phoneNumber ?? 'N/A',
          ),
          _buildInfoRow(
            'Email',
            _user?.email ?? 'N/A',
          ),
          _buildInfoRow(
            'Địa chỉ giao hàng',
            _order?.diaChi ?? _user?.diaChi ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderStatus(String? status) {
    return status.toString();
  }

  Color _getStatusColor(String? status) {
    switch (status.toString()) {
      case 'Chưa xử lý':
        return Colors.orange;
      case 'Đã xác nhận':
        return Colors.blue;
      case 'Đang giao':
        return Colors.purple;
      case 'Đã giao':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.accentColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[50],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin đơn hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Ngày đặt',
                              DateFormat('dd/MM/yyyy')
                                  .format(_order?.ngayDat ?? DateTime.now()),
                            ),
                            _buildInfoRow(
                              'Trạng thái',
                              _getOrderStatus(_order?.trangThai),
                              valueColor: _getStatusColor(_order?.trangThai),
                            ),
                            _buildInfoRow(
                              'Tổng tiền',
                              currencyFormat.format(_order?.tongTien),
                              valueColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUserInfoSection(),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Chi tiết sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _orderItems.length,
                        itemBuilder: (context, index) {
                          final item = _orderItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.product.anhSanPham != null &&
                                            item.product.anhSanPham!.isNotEmpty
                                        ? Image.network(
                                            item.product.anhSanPham!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _buildPlaceholder(),
                                          )
                                        : _buildPlaceholder(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.tenSanPham ??
                                              'Sản phẩm #${item.detail.sanPhamId}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Số lượng: ${item.detail.soLuong}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currencyFormat
                                              .format(item.detail.giaBan),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
