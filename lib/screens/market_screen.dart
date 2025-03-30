import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';
import 'package:fruitshealthy_nhom2/models/DanhMucSanPham.dart';
import 'package:fruitshealthy_nhom2/models/SanPham.dart';
import 'package:fruitshealthy_nhom2/screens/GioiHang_Screen.dart';
import 'package:fruitshealthy_nhom2/screens/ProductDetailScreen.dart';
import 'package:fruitshealthy_nhom2/services/FavoriteService.dart';
import 'package:fruitshealthy_nhom2/services/GioHang_Service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final CartService _cartService = CartService();
  final FavoriteService _favoriteService = FavoriteService();
  Map<int, bool> favoriteStatus = {};
  List<DanhMucSanPham> categories = [];
  List<SanPham> products = [];
  List<SanPham> filteredProducts = [];
  int? selectedCategoryId;
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    _loadFavoriteStatus();
  }

  Future<void> fetchData() async {
    try {
      final categoriesResponse = await http
          .get(Uri.parse('${dotenv.env['BASE_URL']}api/DanhMucSanPhamApi'));
      final productsResponse =
          await http.get(Uri.parse('${dotenv.env['BASE_URL']}api/ProductApi'));

      if (categoriesResponse.statusCode == 200 &&
          productsResponse.statusCode == 200) {
        setState(() {
          categories = (json.decode(categoriesResponse.body) as List)
              .map((item) => DanhMucSanPham.fromJson(item))
              .toList();
          products = (json.decode(productsResponse.body) as List)
              .map((item) => SanPham.fromJson(item))
              .toList();
          filteredProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    for (var product in products) {
      if (product.sanPhamId != null) {
        try {
          bool isFavorite =
              await _favoriteService.isFavorite(product.sanPhamId!);
          if (mounted) {
            setState(() {
              favoriteStatus[product.sanPhamId!] = isFavorite;
            });
          }
        } catch (e) {
          print('Error checking favorite status: $e');
        }
      }
    }
  }

  Future<void> _toggleFavorite(SanPham product) async {
    if (product.sanPhamId == null) return;

    try {
      bool currentStatus = favoriteStatus[product.sanPhamId!] ?? false;
      bool success;

      if (!currentStatus) {
        success = await _favoriteService.addToFavorites(product.sanPhamId!);
      } else {
        success = await _favoriteService.xoaSanPhamYeuThich(product.sanPhamId!);
      }

      if (success && mounted) {
        setState(() {
          favoriteStatus[product.sanPhamId!] = !currentStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !currentStatus
                  ? 'Đã thêm vào danh sách yêu thích'
                  : 'Đã xóa khỏi danh sách yêu thích',
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _addToCart(SanPham product) async {
    try {
      final success = await _cartService.addToCart(product.sanPhamId!, 1);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã thêm vào giỏ hàng'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Xem giỏ hàng',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        bool matchesCategory = selectedCategoryId == null ||
            product.danhMucId == selectedCategoryId;
        bool matchesSearch = searchQuery.isEmpty ||
            product.tenSanPham
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ==
                true;
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
              'Healthy Fruit',
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
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm trái cây...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                searchQuery = value;
                filterProducts();
              },
            ),
          ),
          // Categories
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip(null, 'Tất cả', Icons.grid_view_rounded),
                  ...categories.map((category) => _buildCategoryChip(
                        category.danhMucId,
                        category.tenDanhMuc ?? '',
                        Icons.category_outlined,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Products Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await fetchData();
                      await _loadFavoriteStatus();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int? id, String label, IconData icon) {
    final isSelected = selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        onSelected: (bool selected) {
          setState(() {
            selectedCategoryId = selected ? id : null;
            filterProducts();
          });
        },
      ),
    );
  }

  Widget _buildProductCard(SanPham product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              sanPhamId: product.sanPhamId!,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.anhSanPham ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        favoriteStatus[product.sanPhamId] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                      ),
                      color: favoriteStatus[product.sanPhamId] == true
                          ? Colors.red
                          : Colors.grey,
                      onPressed: () => _toggleFavorite(product),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.tenSanPham ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((product.giaBan ?? 0) / 1000).toStringAsFixed(3)} VNĐ',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add to Cart Button
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text('Thêm vào giỏ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
