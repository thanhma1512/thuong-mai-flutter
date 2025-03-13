class ProductModel {
  String id;
  String name;
  String description;
  double price;
  String imageUrl;
  String category;
  int quantity;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.quantity,
  });

  // Tạo một sản phẩm trống để tránh lỗi
  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      name: 'Sản phẩm không tồn tại',
      description: '',
      price: 0.0,
      imageUrl: '',
      category: '',
      quantity: 0,
    );
  }

  // Chuyển đổi `ProductModel` thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'quantity': quantity,
    };
  }

  // Chuyển đổi từ Firestore thành `ProductModel`
  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
    );
  }
}
