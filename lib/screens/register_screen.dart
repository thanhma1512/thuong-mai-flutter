import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo hoặc icon
                Icon(Icons.person_add, size: 80, color: Colors.blueAccent),

                SizedBox(height: 20),

                // Card chứa form đăng ký
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Tạo tài khoản",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),

                        // Ô nhập tên đăng nhập
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: "Tên đăng nhập",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        // Ô nhập email
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: 15),

                        // Ô nhập mật khẩu
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Mật khẩu",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        // Ô nhập lại mật khẩu
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: "Nhập lại mật khẩu",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorText: _passwordError,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _passwordError = _passwordController.text != value
                                  ? "Mật khẩu không khớp"
                                  : null;
                            });
                          },
                        ),

                        SizedBox(height: 20),

                        // Hiển thị lỗi nếu có
                        Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            return auth.errorMessage != null
                                ? Text(auth.errorMessage!,
                                style: TextStyle(color: Colors.red))
                                : SizedBox.shrink();
                          },
                        ),

                        SizedBox(height: 10),

                        // Nút đăng ký
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: () async {
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              setState(() {
                                _passwordError = "Mật khẩu không khớp";
                              });
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            bool success = await Provider.of<AuthProvider>(context, listen: false)
                                .register(
                                _usernameController.text,
                                _emailController.text,
                                _passwordController.text,
                                _confirmPasswordController.text);

                            if (success) {
                              Navigator.pop(context);
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Đăng ký", style: TextStyle(fontSize: 16)),
                        ),

                        SizedBox(height: 15),

                        // Nút quay lại đăng nhập
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Đã có tài khoản? Đăng nhập ngay"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
