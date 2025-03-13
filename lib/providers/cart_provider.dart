import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CartProvider with ChangeNotifier {

  final Map<String, CartItemModel> _items = {};
  Map<String, CartItemModel> get items => _items;

  List<Map<String, dynamic>> _orderHistory = []; // 🔥 Lưu lịch sử đơn hàng
  List<Map<String, dynamic>> get orderHistory => _orderHistory;

  /// 📌 Tính tổng số tiền trong giỏ hàng
  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// 📌 Tính tổng số lượng sản phẩm trong giỏ hàng
  int get totalItemsCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 📌 Lấy số lượng sản phẩm trong giỏ hàng theo ID sản phẩm
  int getItemQuantity(String productId) {
    return _items.containsKey(productId) ? _items[productId]!.quantity : 0;
  }

  /// 📌 Thêm sản phẩm vào giỏ hàng (Giới hạn theo số lượng hàng tồn kho)
  void addToCart(CartItemModel cartItem, int stockQuantity) {
    if (_items.containsKey(cartItem.id)) {
      if (_items[cartItem.id]!.quantity < stockQuantity) {
        _items.update(
          cartItem.id,
              (existingItem) => existingItem.copyWith(quantity: existingItem.quantity + 1),
        );
      } else {
        print("⚠️ Số lượng sản phẩm đã đạt giới hạn!");
      }
    } else {
      if (stockQuantity > 0) {
        _items.putIfAbsent(cartItem.id, () => cartItem.copyWith(quantity: 1));
      } else {
        print("⚠️ Hết hàng! Không thể thêm vào giỏ.");
      }
    }
    notifyListeners();
  }

  /// 📌 Giảm số lượng sản phẩm (Nếu còn >1 thì giảm, nếu =1 thì xóa)
  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
            (existingItem) => existingItem.copyWith(quantity: existingItem.quantity - 1),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// 📌 Cập nhật số lượng sản phẩm trong giỏ hàng
  void updateQuantity(String productId, int newQuantity, int stockQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity > 0 && newQuantity <= stockQuantity) {
      _items.update(
        productId,
            (existingItem) => existingItem.copyWith(quantity: newQuantity),
      );
    } else if (newQuantity == 0) {
      _items.remove(productId);
    } else {
      print("⚠️ Số lượng vượt quá hàng tồn kho!");
    }
    notifyListeners();
  }

  /// 📌 Xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// 📌 Xóa toàn bộ giỏ hàng
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// 📌 Lưu đơn hàng vào lịch sử
  Future<void> saveOrder(String name, String phone, String address, String paymentMethod) async {
    if (_items.isEmpty) return;

    final orderData = {
      "name": name,
      "phone": phone,
      "address": address,
      "paymentMethod": paymentMethod,
      "totalAmount": totalAmount,
      "items": _items.values.map((item) => {
        "id": item.id,
        "name": item.name,
        "quantity": item.quantity,
        "price": item.price,
        "imageUrl": item.imageUrl,
      }).toList(),
      "orderDate": Timestamp.now(), // Firestore hỗ trợ Timestamp
    };

    try {
      await FirebaseFirestore.instance.collection("orders").add(orderData);
      _orderHistory.insert(0, orderData);
      _items.clear();
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi khi lưu đơn hàng: $e");
    }
  }
}
