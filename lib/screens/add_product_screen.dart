import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../services/firebase_product_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _imageUrlController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();  // Thêm controller cho quantity
  String _selectedCategory = "Điện thoại";

  List<String> categories = ["Điện thoại", "Laptop", "Phụ kiện"];

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Tạo ID tự động
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        quantity: int.parse(_quantityController.text), // Sử dụng quantity từ input
      );

      await FirebaseProductService.addProduct(newProduct); // Thêm sản phẩm vào Firestore

      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm Sản Phẩm"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Nút quay về
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Tên sản phẩm"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Mô tả sản phẩm"),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Nhập mô tả sản phẩm" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Giá sản phẩm"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: "URL Ảnh sản phẩm"),
                onChanged: (value) {
                  setState(() {}); // Cập nhật ảnh khi nhập URL
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: "Số lượng sản phẩm"), // Trường nhập số lượng
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Nhập số lượng sản phẩm" : null,
              ),
              DropdownButtonFormField(
                value: _selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value.toString();
                  });
                },
                decoration: InputDecoration(labelText: "Danh mục"),
              ),
              SizedBox(height: 10),
              _imageUrlController.text.isNotEmpty
                  ? Image.network(
                _imageUrlController.text,
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 150, color: Colors.grey),
              )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text("Thêm Sản Phẩm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
