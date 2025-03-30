import 'package:flutter/material.dart';
import 'package:fruitshealthy_nhom2/models/DanhMucYeuThich.dart';
import 'package:fruitshealthy_nhom2/models/SanPham.dart';
import 'package:fruitshealthy_nhom2/screens/ProductDetailScreen.dart';
import 'package:fruitshealthy_nhom2/services/FavoriteService.dart';
import 'package:fruitshealthy_nhom2/services/GioHang_Service.dart';
import 'package:fruitshealthy_nhom2/services/ProductService.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';
import 'package:intl/intl.dart';
import 'package:fruitshealthy_nhom2/screens/GioiHang_Screen.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favoriteService = FavoriteService();
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  List<Map<String, dynamic>> _favoriteProducts = [];
  bool _isLoading = true;
  String _error = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final favorites = await _favoriteService.getFavoriteProducts();
      _favoriteProducts = [];

      for (var favorite in favorites) {
        if (favorite.sanPhamId != null) {
          try {
            final product =
                await _productService.getProductById(favorite.sanPhamId!);
            _favoriteProducts.add({
              'favorite': favorite,
              'product': product,
            });
          } catch (e) {
            print('Error loading product ${favorite.sanPhamId}: $e');
          }
        }
      }

      _favoriteProducts.sort((a, b) {
        final timeA = (a['favorite'] as DanhMucYeuThich).danhMucYeuThichId ?? 1;
        final timeB = (b['favorite'] as DanhMucYeuThich).danhMucYeuThichId ?? 1;
        return timeB.compareTo(timeA);
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> getFilteredProducts() {
    if (searchQuery.isEmpty) return _favoriteProducts;

    return _favoriteProducts.where((item) {
      final product = item['product'] as SanPham;
      return product.tenSanPham
              ?.toLowerCase()
              .contains(searchQuery.toLowerCase()) ??
          false;
    }).toList();
  }

  Future<void> _addToCart(SanPham product) async {
    try {
      final success = await _cartService.addToCart(product.sanPhamId!, 1);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã thêm vào giỏ hàng'),
            backgroundColor: const Color(0xFF4CAF50),
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

  Future<void> _removeFavorite(DanhMucYeuThich favorite) async {
    try {
      final success = await _favoriteService
          .xoaSanPhamYeuThich(favorite.danhMucYeuThichId!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi danh sách yêu thích'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          ),
        );
        await _loadFavorites();
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
              'Sản phẩm yêu thích',
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
                hintText: 'Tìm kiếm trong yêu thích...',
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
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: getFilteredProducts().isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_border,
                                        size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Chưa có sản phẩm yêu thích nào',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.5,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: getFilteredProducts().length,
                                itemBuilder: (context, index) {
                                  final favorite = getFilteredProducts()[index]
                                      ['favorite'] as DanhMucYeuThich;
                                  final product = getFilteredProducts()[index]
                                      ['product'] as SanPham;
                                  return _buildProductCard(product, favorite);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(SanPham product, DanhMucYeuThich favorite) {
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () => _removeFavorite(favorite),
                    ),
                  ),
                ),
              ],
            ),
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
                    currencyFormat.format(product.giaBan ?? 0),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (favorite.thoiGian != null)
                    Text(
                      'Đã thêm: ${favorite.thoiGian!.day}/${favorite.thoiGian!.month}/${favorite.thoiGian!.year}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
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
}
