import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';


class ProductItem extends StatelessWidget {
  final ProductModel product;

  ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false); // 🔥 Lấy ProductProvider để cập nhật số lượng

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, url, error) =>
                      Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${NumberFormat("#,###", "vi_VN").format(product.price)} ₫",
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Consumer<ProductProvider>(
                    builder: (context, provider, child) {
                      final updatedProduct = provider.getProductById(product.id);
                      return Text(
                        "Còn lại: ${updatedProduct?.quantity ?? product.quantity}",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: product.quantity > 0
                          ? () {
                        if (cartProvider.getItemQuantity(product.id) < product.quantity) {
                          final cartItem = CartItemModel(
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            quantity: 1,
                            imageUrl: product.imageUrl,
                          );

                          cartProvider.addToCart(cartItem, product.quantity);

                          // 🔥 Giảm số lượng sản phẩm và cập nhật UI
                          final updatedProduct = ProductModel(
                            id: product.id,
                            name: product.name,
                            description: product.description,
                            category: product.category,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            quantity: product.quantity - 1, // 🔥 Trừ số lượng sau khi thêm vào giỏ hàng
                          );
                          productProvider.updateProduct(product.id, updatedProduct); // ✅ Cập nhật số lượng trong Provider

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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("⚠️ Số lượng sản phẩm đã đạt giới hạn!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: product.quantity > 0 ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        product.quantity > 0 ? "🛒 Thêm vào giỏ hàng" : "⛔ Hết hàng",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
