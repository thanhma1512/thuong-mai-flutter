import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedPaymentMethod = "Ship COD"; // 🌟 Mặc định là Ship COD
  bool _showQRCode = false;

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  /// ✅ Xử lý xác nhận đơn hàng
  void _confirmOrder(BuildContext context, CartProvider cartProvider) {
    if (_formKey.currentState!.validate()) {
      if (_selectedPaymentMethod == "Chuyển khoản ngân hàng") {
        setState(() {
          _showQRCode = true;
        });
      } else {
        cartProvider.saveOrder(
          _nameController.text,
          _phoneController.text,
          _addressController.text,
          _selectedPaymentMethod,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Đơn hàng đã được đặt thành công!")),
        );

        Navigator.pop(context);
      }
    }
  }


  /// 🏦 Tạo dữ liệu QR Code
  String generateQRCodeData(double amount) {
    return "Ngân hàng: Vietcombank\n"
        "Số tài khoản: 0123456789\n"
        "Chủ tài khoản: Nguyễn Văn A\n"
        "Số tiền: ${formatCurrency(amount)}\n"
        "Nội dung: Thanh toán đơn hàng";
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text("🛍️ Xác nhận đơn hàng")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // 📝 Form nhập thông tin giao hàng
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Họ và Tên"),
                      validator: (value) => value!.isEmpty ? "Vui lòng nhập tên" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: "Số điện thoại"),
                      validator: (value) => value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: "Địa chỉ giao hàng"),
                      validator: (value) => value!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                    ),
                    SizedBox(height: 10),
                    // 💳 Chọn phương thức thanh toán
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      items: ["Ship COD", "Chuyển khoản ngân hàng"].map((method) {
                        return DropdownMenuItem(value: method, child: Text(method));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                          _showQRCode = (value == "Chuyển khoản ngân hàng"); // 🌟 Cập nhật trạng thái QR Code
                        });
                      },
                      decoration: InputDecoration(labelText: "Phương thức thanh toán"),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Divider(),
              // 📦 Danh sách sản phẩm
              Text(
                "🛒 Sản phẩm trong đơn hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: cartItems.map((item) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    child: ListTile(
                      leading: Image.network(
                        item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                      title: Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      subtitle: Text("Số lượng: ${item.quantity}"),
                      trailing: Text(
                        formatCurrency(item.price * item.quantity),
                        style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Divider(),
              // 💰 Tổng tiền
              Text(
                "Tổng tiền: ${formatCurrency(cartProvider.totalAmount)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // 🔥 Hiển thị QR Code nếu chọn "Chuyển khoản ngân hàng"
              if (_showQRCode)
                Column(
                  children: [
                    Text("🔹 Quét mã QR để thanh toán:", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    QrImageView(
                      data: generateQRCodeData(cartProvider.totalAmount),
                      version: QrVersions.auto,
                      size: 200,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("✅ Thanh toán thành công!")),
                        );
                        cartProvider.clearCart();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "✅ Xác nhận đã thanh toán",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              // 🔘 Nút xác nhận thanh toán
              if (!_showQRCode)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmOrder(context, cartProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "🎉 Xác nhận đặt hàng",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
