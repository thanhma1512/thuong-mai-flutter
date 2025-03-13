import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;
  late ProductModel _product; // Thêm biến lưu product

  final List<String> _categories = ["Điện thoại", "Laptop", "Phụ kiện"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProductModel) {
      _product = args;
      _nameController = TextEditingController(text: _product.name);
      _descriptionController = TextEditingController(text: _product.description);
      _priceController = TextEditingController(text: _product.price.toString());
      _quantityController = TextEditingController(text: _product.quantity.toString());
      _imageUrlController = TextEditingController(text: _product.imageUrl);
      _selectedCategory = _product.category;
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = ProductModel(
        id: _product.id,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: _imageUrlController.text,
      );

      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(_product.id, updatedProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật sản phẩm thành công!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa sản phẩm")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Giá"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: "Số lượng"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(labelText: "Danh mục"),
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: "Hình ảnh URL"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text("Lưu chỉnh sửa"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
