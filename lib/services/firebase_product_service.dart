import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseProductService {
  static final CollectionReference _productCollection =
  FirebaseFirestore.instance.collection('products');

  // 📌 Thêm sản phẩm vào Firestore
  static Future<void> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef = await _productCollection.add(product.toMap());
      await docRef.update({'id': docRef.id}); // 🔥 Cập nhật ID cho sản phẩm
    } catch (e) {
      print("🔥 Lỗi khi thêm sản phẩm: $e");
      throw e;
    }
  }

  // 📌 Cập nhật sản phẩm trong Firestore
  static Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      await _productCollection.doc(productId).update(product.toMap());
    } catch (e) {
      print("🔥 Lỗi khi cập nhật sản phẩm: $e");
      throw e;
    }
  }

  // 📌 Xóa sản phẩm khỏi Firestore
  static Future<void> deleteProduct(String productId) async {
    try {
      await _productCollection.doc(productId).delete();
    } catch (e) {
      print("🔥 Lỗi khi xóa sản phẩm: $e");
      throw e;
    }
  }

  // 📌 Lấy danh sách sản phẩm từ Firestore
  static Future<List<ProductModel>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _productCollection.get();
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("🔥 Lỗi khi lấy danh sách sản phẩm: $e");
      return [];
    }
  }
}
