import 'package:fruitshealthy_nhom2/screens/OrderDetailPage.dart';
import 'package:fruitshealthy_nhom2/services/DonHangService%20.dart';
import 'package:flutter/material.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';
import 'package:intl/intl.dart';
import 'package:fruitshealthy_nhom2/models/DonHang.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final DonHangService _orderService = DonHangService();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  List<DonHang> _orders = [];
  List<DonHang> _filteredOrders = [];
  bool _isLoading = true;
  String _error = '';
  String? _selectedStatus;

  final List<String> orderStatuses = [
    'Tất cả',
    'Chưa xử lý',
    'Đã xác nhận',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _filterOrders(String? status) {
    setState(() {
      _selectedStatus = status;
      if (status == null || status == 'Tất cả') {
        _filteredOrders = List.from(_orders);
      } else {
        _filteredOrders =
            _orders.where((order) => order.trangThai == status).toList();
      }
    });
  }
  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final orders = await _orderService.getOrdersByUserId();
      orders.sort((a, b) {
        final timeA = (a).donHangId ?? 1;
        final timeB = (b).donHangId ?? 1;
        return timeB.compareTo(timeA);
      });
      setState(() {
        _orders = orders;
        _filterOrders(_selectedStatus);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: orderStatuses.length,
        itemBuilder: (context, index) {
          final status = orderStatuses[index];
          final isSelected = _selectedStatus == status ||
              (status == 'Tất cả' && _selectedStatus == null);

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == orderStatuses.length - 1 ? 16 : 0,
            ),
            child: FilterChip(
              selected: isSelected,
              label: Text(status),
              onSelected: (bool selected) {
                _filterOrders(selected ? status : null);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: _getStatusColor(status).withOpacity(0.2),
              checkmarkColor: _getStatusColor(status),
              labelStyle: TextStyle(
                color: isSelected ? _getStatusColor(status) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
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
              'Đơn hàng',
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
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    _buildFilterChips(),
                    Expanded(
                      child: _filteredOrders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 72, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                      _selectedStatus == null
                                          ? 'Chưa có đơn hàng nào'
                                          : 'Không có đơn hàng $_selectedStatus',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderDetailPage(
                                              orderId: order.donHangId!),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Đơn hàng #${order.donHangId}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          order.trangThai)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  _getOrderStatus(
                                                      order.trangThai),
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                        order.trangThai),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Ngày đặt: ${DateFormat('dd/MM/yyyy').format(order.ngayDat ?? DateTime.now())}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                currencyFormat
                                                    .format(order.tongTien),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
