import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryScreen extends StatelessWidget {
  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderHistory = cartProvider.orderHistory;

    return Scaffold(
      appBar: AppBar(title: Text("📜 Lịch sử đơn hàng")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("orders").orderBy("orderDate", descending: true).snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("❌ Bạn chưa có đơn hàng nào."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final order = orders[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
                child: ExpansionTile(
                  title: Text(
                    "🛍 Đơn hàng ${DateFormat('dd/MM/yyyy – HH:mm').format((order["orderDate"] as Timestamp).toDate())}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("💳 ${order["paymentMethod"]} - ${formatCurrency(order["totalAmount"])}"),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("👤 Khách hàng: ${order["name"]}"),
                          Text("📞 Số điện thoại: ${order["phone"]}"),
                          Text("📍 Địa chỉ: ${order["address"]}"),
                          Divider(),
                          Text("🛒 Danh sách sản phẩm:"),
                          ...order["items"].map<Widget>((item) {
                            return ListTile(
                              title: Text(item["name"]),
                              subtitle: Text("Số lượng: ${item["quantity"]}"),
                              trailing: Text(formatCurrency(item["price"] * item["quantity"])),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
