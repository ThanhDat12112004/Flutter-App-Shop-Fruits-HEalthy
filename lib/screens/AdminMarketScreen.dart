import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fruitshealthy_nhom2/models/SanPham.dart';
import 'package:fruitshealthy_nhom2/models/DanhMucSanPham.dart';
import 'package:fruitshealthy_nhom2/theme/apptheme.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<SanPham> products = [];
  List<DanhMucSanPham> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final productsResponse = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/ProductApi'),
      );
      final categoriesResponse = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}api/DanhMucSanPhamApi'),
      );

      if (productsResponse.statusCode == 200 &&
          categoriesResponse.statusCode == 200) {
        setState(() {
          products = (json.decode(productsResponse.body) as List)
              .map((item) => SanPham.fromJson(item))
              .toList();
          categories = (json.decode(categoriesResponse.body) as List)
              .map((item) => DanhMucSanPham.fromJson(item))
              .toList();
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

  Future<void> deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}api/ProductApi/$productId'),
      );

      if (response.statusCode == 204) {
        setState(() {
          products.removeWhere((product) => product.sanPhamId == productId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sản phẩm đã được xóa')),
          );
        }
      }
    } catch (e) {
      print('Error deleting product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa sản phẩm')),
        );
      }
    }
  }

  Future<void> editProduct(SanPham product) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductEditDialog(
        product: product,
        categories: categories,
      ),
    );

    if (result != null) {
      try {
        final response = await http.put(
          Uri.parse(
              '${dotenv.env['BASE_URL']}api/ProductApi/${product.sanPhamId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(result),
        );

        if (response.statusCode == 204) {
          fetchData(); // Refresh the product list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sản phẩm đã được cập nhật')),
            );
          }
        }
      } catch (e) {
        print('Error updating product: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể cập nhật sản phẩm')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.network(
                          product.anhSanPham ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(product.tenSanPham ?? ''),
                      subtitle: Text(
                        'Giá: ${((product.giaBan ?? 0) / 1000).toStringAsFixed(3)} VNĐ\n'
                        'Số lượng: ${product.soLuongTon}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editProduct(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: const Text(
                                    'Bạn có chắc muốn xóa sản phẩm này?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteProduct(product.sanPhamId!);
                                    },
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add new product functionality
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => ProductEditDialog(
              categories: categories,
            ),
          );

          if (result != null) {
            try {
              final response = await http.post(
                Uri.parse('${dotenv.env['BASE_URL']}api/ProductApi'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(result),
              );

              if (response.statusCode == 201) {
                fetchData(); // Refresh the product list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sản phẩm mới đã được thêm')),
                  );
                }
              }
            } catch (e) {
              print('Error adding product: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không thể thêm sản phẩm mới')),
                );
              }
            }
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductEditDialog extends StatefulWidget {
  final SanPham? product;
  final List<DanhMucSanPham> categories;

  const ProductEditDialog({
    super.key,
    this.product,
    required this.categories,
  });

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController imageController;
  late TextEditingController descriptionController;
  late int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.product?.tenSanPham ?? '');
    priceController =
        TextEditingController(text: widget.product?.giaBan?.toString() ?? '');
    stockController = TextEditingController(
        text: widget.product?.soLuongTon?.toString() ?? '');
    imageController =
        TextEditingController(text: widget.product?.anhSanPham ?? '');
    descriptionController =
        TextEditingController(text: widget.product?.moTa ?? '');
    selectedCategoryId = widget.product?.danhMucId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.product == null ? 'Thêm sản phẩm' : 'Chỉnh sửa sản phẩm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Giá bán'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Số lượng tồn'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'URL ảnh'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              items: widget.categories
                  .map((category) => DropdownMenuItem(
                        value: category.danhMucId,
                        child: Text(category.tenDanhMuc ?? ''),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Danh mục'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            final Map<String, Object?> productData;
            if (widget.product != null) {
              productData = {
                'sanPhamId': widget.product!.sanPhamId,
                'tenSanPham': nameController.text,
                'giaBan': int.tryParse(priceController.text) ?? 0,
                'soLuongTon': int.tryParse(stockController.text) ?? 0,
                'anhSanPham': imageController.text,
                'moTa': descriptionController.text,
                'danhMucId': selectedCategoryId,
              };
            } else {
              productData = {
                // 'sanPhamId': widget.product!.sanPhamId,
                'tenSanPham': nameController.text,
                'giaBan': int.tryParse(priceController.text) ?? 0,
                'soLuongTon': int.tryParse(stockController.text) ?? 0,
                'anhSanPham': imageController.text,
                'moTa': descriptionController.text,
                'danhMucId': selectedCategoryId,
              };
            }
            Navigator.pop(context, productData);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
