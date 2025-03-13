import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firebase_product_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  String _selectedCategory = "Tất cả";

  List<ProductModel> get products => _products;
  String get selectedCategory => _selectedCategory;

  // 📌 Lấy danh sách sản phẩm từ Firestore
  Future<void> fetchProducts() async {
    _products = await FirebaseProductService.getProducts();
    notifyListeners();
  }

  // 📌 Lấy sản phẩm theo ID
  ProductModel? getProductById(String id) {
    return _products.firstWhere((product) => product.id == id, orElse: () => ProductModel.empty());
  }

  // 📌 Lọc sản phẩm theo danh mục và từ khóa tìm kiếm
  List<ProductModel> filteredProducts(String query, String category) {
    return _products.where((product) {
      bool matchesCategory = category == "Tất cả" || product.category == category;
      bool matchesQuery = query.trim().isEmpty || product.name.toLowerCase().contains(query.trim().toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // 📌 Thêm sản phẩm vào Firestore
  Future<void> addProduct(ProductModel product) async {
    await FirebaseProductService.addProduct(product);
    _products.add(product);
    notifyListeners();
  }

  // 📌 Cập nhật sản phẩm trong Firestore
  Future<void> updateProduct(String productId, ProductModel updatedProduct) async {
    await FirebaseProductService.updateProduct(productId, updatedProduct); // 🔥 Cập nhật Firestore trước
    int index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners(); // 🔥 Cập nhật UI
    }
  }

  // 📌 Xóa sản phẩm khỏi Firestore
  Future<void> deleteProduct(String productId) async {
    await FirebaseProductService.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}
