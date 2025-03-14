import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "Tất cả"; // 🔥 Bộ lọc danh mục
  List<String> categories = ["Tất cả", "Điện thoại", "Laptop", "Phụ kiện"];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    setState(() {
      _isLoading = false;
    });
  }

  void _deleteProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ProductProvider>(context, listen: false).deleteProduct(productId);
    await _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Sản phẩm đã được xóa!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredProducts = productProvider.filteredProducts(_searchQuery, _selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text("📦 Danh sách sản phẩm"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductScreen()),
            ).then((_) => _loadProducts()), // 🔥 Load lại sau khi thêm
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: "🔍 Tìm kiếm sản phẩm",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // 🔥 Bộ lọc danh mục
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              decoration: InputDecoration(
                labelText: "📂 Chọn danh mục",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // 📦 Danh sách sản phẩm
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? Center(child: Text("🚫 Không có sản phẩm nào!"))
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${NumberFormat("#,###", "vi_VN").format(product.price)} ₫",
                          style: TextStyle(fontSize: 14, color: Colors.redAccent),
                        ),
                        Text(
                          "Kho: ${product.quantity} sản phẩm",
                          style: TextStyle(
                            color: product.quantity > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✏️ Chỉnh sửa sản phẩm
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/edit_product_screen',
                              arguments: product, // ✅ Truyền tham số product
                            ).then((_) => _loadProducts());
                          },
                        ),

                        // 🗑️ Xóa sản phẩm
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("⚠ Xóa sản phẩm"),
                                content: Text("Bạn có chắc chắn muốn xóa sản phẩm này?"),
                                actions: [
                                  TextButton(
                                    child: Text("Hủy"),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                  TextButton(
                                    child: Text("Xóa", style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      _deleteProduct(product.id);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
