import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Màu nền nhẹ nhàng
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo hoặc biểu tượng
                Icon(Icons.lock, size: 80, color: Colors.blueAccent),

                SizedBox(height: 20),

                // Card chứa form đăng nhập
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
                          "Đăng nhập",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),

                        // Ô nhập Email hoặc Username
                        TextField(
                          controller: _identifierController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: "Email hoặc Tên đăng nhập",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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

                        // Nút đăng nhập
                        _isLoading
                            ? CircularProgressIndicator() // Hiển thị khi đang xử lý
                            : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            bool success = await Provider.of<AuthProvider>(context, listen: false)
                                .login(_identifierController.text, _passwordController.text);

                            if (success) {
                              Navigator.pushReplacementNamed(context, '/home');
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
                          child: Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                        ),

                        SizedBox(height: 15),

                        // Nút đăng ký
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text("Đăng ký tài khoản mới"),
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
