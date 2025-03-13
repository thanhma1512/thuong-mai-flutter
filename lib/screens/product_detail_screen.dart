import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart' as cart_provider;
import '../providers/product_provider.dart' as product_provider;

class ProductDetailScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel product;
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 1000;

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product = ModalRoute.of(context)!.settings.arguments as ProductModel;
    _pageController = PageController(initialPage: _currentPage, viewportFraction: 0.85);

    // 🌟 Tạo vòng lặp vô hạn tự động trượt
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<cart_provider.CartProvider>(context);
    final productProvider = Provider.of<product_provider.ProductProvider>(context);
    final relatedProducts = productProvider.products
        .where((p) => p.category == product.category && p.id != product.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, size: 28),
                if (cartProvider.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartProvider.items.length.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/cart");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Giá: ${formatCurrency(product.price)}",
                      style: TextStyle(fontSize: 18, color: Colors.green)),
                  SizedBox(height: 10),
                  Text("Mô tả sản phẩm:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(
                    product.description.isNotEmpty ? product.description : "Không có mô tả",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.shopping_cart),
                      label: Text("Thêm vào giỏ hàng"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      onPressed: () {
                        final cartItem = CartItemModel(
                          id: product.id,
                          name: product.name,
                          price: product.price,
                          quantity: 1,
                          imageUrl: product.imageUrl,
                        );

                        cartProvider.addToCart(cartItem, product.quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("✅ Đã thêm ${product.name} vào giỏ hàng"),
                            duration: Duration(seconds: 2),
                            action: SnackBarAction(
                              label: "Xem giỏ hàng",
                              onPressed: () {
                                Navigator.pushNamed(context, "/cart");
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  if (relatedProducts.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🔥 Sản phẩm liên quan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemBuilder: (ctx, index) {
                              final relatedProduct = relatedProducts[index % relatedProducts.length];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    product = relatedProduct;
                                    _currentPage = 1000;
                                    _pageController.jumpToPage(1000);
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 4),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                        child: Image.network(
                                          relatedProduct.imageUrl,
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Text(
                                              relatedProduct.name,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              formatCurrency(relatedProduct.price),
                                              style: TextStyle(color: Colors.green),
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
                        ),
                      ],
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
