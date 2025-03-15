import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Hiển thị tiến trình khi đang cập nhật
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    bool success = await authProvider.updateUser(
      username: _usernameController.text,
      fullname: _fullnameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      avatarFile: _imageFile,
    );

    // Đóng dialog loading
    Navigator.of(context).pop();

    if (success) {
      // ✅ Cập nhật ngay dữ liệu người dùng trong `authProvider`
      await authProvider.fetchCurrentUser();

      // ✅ Cập nhật UI ngay lập tức
      setState(() {
        _isEditing = false;
        _imageFile = null;
        _usernameController.text = authProvider.currentUser?.username ?? "";
        _fullnameController.text = authProvider.currentUser?.fullname ?? "";
        _emailController.text = authProvider.currentUser?.email ?? "";
        _phoneController.text = authProvider.currentUser?.phone ?? "";
        _addressController.text = authProvider.currentUser?.address ?? "";
      });

      // ✅ Hiển thị thông báo cập nhật thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Cập nhật thành công!"), duration: Duration(seconds: 2)),
      );
    } else {
      // ❌ Hiển thị thông báo lỗi nếu cập nhật thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Cập nhật thất bại!"), duration: Duration(seconds: 2)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    _usernameController.text = user?.username ?? "";
    _fullnameController.text = user?.fullname ?? "";
    _phoneController.text = user?.phone ?? "";
    _emailController.text = user?.email ?? "";
    _addressController.text = user?.address ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("👤 Tài khoản", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar & Button Chọn Ảnh
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null) as ImageProvider?,
                      child: _imageFile == null && user?.avatarUrl == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Form thông tin người dùng
            buildTextField("👤 Tên người dùng", _usernameController, enabled: false),
            buildTextField("📛 Họ tên", _fullnameController, enabled: _isEditing),
            buildTextField("📧 Email", _emailController, enabled: _isEditing),
            buildTextField("📞 Số điện thoại", _phoneController, enabled: _isEditing),
            buildTextField("📍 Địa chỉ", _addressController, enabled: _isEditing),

            SizedBox(height: 20),

            // Button Đăng Xuất
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              onPressed: () async {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("🚪 Đăng xuất", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              border: InputBorder.none,

            ),
          ),
        ),
      ),
    );
  }
}
