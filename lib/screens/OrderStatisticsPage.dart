import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fruitshealthy_nhom2/models/DonHang.dart';
import 'package:fruitshealthy_nhom2/services/DonHangService%20.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';
import 'package:fl_chart/fl_chart.dart';

class OrderStatisticsPage extends StatefulWidget {
  const OrderStatisticsPage({super.key});

  @override
  _OrderStatisticsPageState createState() => _OrderStatisticsPageState();
}

class _OrderStatisticsPageState extends State<OrderStatisticsPage> {
  final DonHangService _orderService = DonHangService();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  List<DonHang> _completedOrders = [];
  bool _isLoading = true;
  String _error = '';

  // Filter variables
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _filterType = 'day'; // 'day', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
  }

  Future<void> _loadCompletedOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final allOrders = await _orderService.getOrders();
      final completedOrders = allOrders
          .where((order) => order.trangThai == 'Đã giao')
          .where((order) {
        final orderDate = order.ngayDat ?? DateTime.now();
        return orderDate.isAfter(_startDate) &&
            orderDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      setState(() {
        _completedOrders = completedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateStatistics() {
    if (_completedOrders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0,
        'averageOrderValue': 0,
        'minOrderValue': 0,
        'maxOrderValue': 0,
      };
    }

    final totalOrders = _completedOrders.length;
    final totalRevenue = _completedOrders.fold<double>(
        0, (sum, order) => sum + (order.tongTien ?? 0));
    final averageOrderValue = totalRevenue / totalOrders;
    final minOrderValue = _completedOrders
        .map((order) => order.tongTien ?? 0)
        .reduce((a, b) => a < b ? a : b);
    final maxOrderValue = _completedOrders
        .map((order) => order.tongTien ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'minOrderValue': minOrderValue,
      'maxOrderValue': maxOrderValue,
    };
  }

  List<FlSpot> _getChartData() {
    final Map<int, double> groupedData = {};

    for (var order in _completedOrders) {
      final date = order.ngayDat ?? DateTime.now();
      int key;

      switch (_filterType) {
        case 'day':
          key =
              DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
          break;
        case 'month':
          key = DateTime(date.year, date.month).millisecondsSinceEpoch;
          break;
        case 'year':
          key = DateTime(date.year).millisecondsSinceEpoch;
          break;
        default:
          key =
              DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      }

      groupedData[key] = (groupedData[key] ?? 0) + (order.tongTien ?? 0);
    }

    double index = 0;
    return groupedData.entries.map((e) => FlSpot(index++, e.value)).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  List<String> _getXAxisLabels() {
    final List<String> labels = [];

    for (var order in _completedOrders) {
      final date = order.ngayDat ?? DateTime.now();
      String label;

      switch (_filterType) {
        case 'day':
          label = DateFormat('dd/MM').format(date);
          break;
        case 'month':
          label = DateFormat('MM/yyyy').format(date);
          break;
        case 'year':
          label = DateFormat('yyyy').format(date);
          break;
        default:
          label = DateFormat('dd/MM').format(date);
      }

      if (!labels.contains(label)) {
        labels.add(label);
      }
    }

    return labels;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadCompletedOrders();
    }
  }

  Widget _buildStatisticsCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final spots = _getChartData();
    final labels = _getXAxisLabels();

    if (spots.isEmpty) {
      return const Center(
        child: Text('Không có dữ liệu để hiển thị'),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    currencyFormat.format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.blue,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statistics = _calculateStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê đơn hàng',
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date range and filter controls
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _filterType,
                            items: const [
                              DropdownMenuItem(
                                value: 'day',
                                child: Text('Ngày'),
                              ),
                              DropdownMenuItem(
                                value: 'month',
                                child: Text('Tháng'),
                              ),
                              DropdownMenuItem(
                                value: 'year',
                                child: Text('Năm'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _filterType = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Statistics cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatisticsCard(
                            'Tổng số đơn',
                            statistics['totalOrders'].toString(),
                          ),
                          _buildStatisticsCard(
                            'Tổng doanh thu',
                            currencyFormat.format(statistics['totalRevenue']),
                          ),
                          _buildStatisticsCard(
                            'Giá trị trung bình',
                            currencyFormat
                                .format(statistics['averageOrderValue']),
                          ),
                          _buildStatisticsCard(
                            'Đơn hàng cao nhất',
                            currencyFormat.format(statistics['maxOrderValue']),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Revenue chart
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biểu đồ doanh thu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildChart(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
