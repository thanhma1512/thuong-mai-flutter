import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:intl/intl.dart';

import 'checkout_screen.dart'; // 🌟 Định dạng tiền VND

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentPage = 0;
  final int _itemsPerPage = 6;

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();
    final int totalPages = (cartItems.length / _itemsPerPage).ceil();
    final List<List> paginatedItems = List.generate(
      totalPages,
          (index) => cartItems.skip(index * _itemsPerPage).take(_itemsPerPage).toList(),
    );

    return Scaffold(
      appBar: AppBar(title: Text("🛒 Giỏ hàng")),
      body: cartItems.isEmpty
          ? Center(child: Text("Giỏ hàng trống!"))
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: paginatedItems.length,
              controller: PageController(viewportFraction: 1),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: paginatedItems[pageIndex].length,
                  itemBuilder: (ctx, index) {
                    final item = paginatedItems[pageIndex][index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: ListTile(
                        leading: item.imageUrl != null
                            ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.image, size: 50, color: Colors.grey),
                        title: Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Giá: ${formatCurrency(item.price)}",
                                style: TextStyle(fontSize: 14, color: Colors.green)),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, color: Colors.red),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      cartProvider.updateQuantity(item.id, item.quantity - 1, item.maxQuantity);
                                    } else {
                                      cartProvider.removeFromCart(item.id);
                                    }
                                  },
                                ),
                                Text(item.quantity.toString(), style: TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: Icon(Icons.add, color: Colors.blue),
                                  onPressed: () {
                                    if (item.quantity < item.maxQuantity) {
                                      cartProvider.updateQuantity(item.id, item.quantity + 1, item.maxQuantity);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("⚠️ Không thể thêm, đã đạt giới hạn số lượng!"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cartProvider.removeFromCart(item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildPaginationControls(totalPages),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Tổng tiền: ${formatCurrency(cartProvider.totalAmount)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutScreen()),
                    );
                  },
                  child: Text("🛍️ Thanh toán"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentPage = index;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blue : Colors.grey[300],
              ),
            ),
          );
        }),
      ),
    );
  }
}
