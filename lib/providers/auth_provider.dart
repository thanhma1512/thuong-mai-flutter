import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';


class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser; // 🌟 Lưu trữ thông tin người dùng hiện tại
  String? _errorMessage;

  UserModel? get currentUser => _currentUser; // ✅ Getter cho currentUser
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadCurrentUser(); // ✅ Tải dữ liệu khi khởi tạo
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      _currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      _errorMessage = "Mật khẩu không khớp!";
      notifyListeners();
      return false;
    }

    try {
      var existingUser = await _firestore.collection('users').where('username', isEqualTo: username).get();
      if (existingUser.docs.isNotEmpty) {
        _errorMessage = "Tên đăng nhập đã tồn tại!";
        notifyListeners();
        return false;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());
      _currentUser = newUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String identifier, String password) async {
    try {
      String email = identifier;
      if (!identifier.contains('@')) {
        var userDoc = await _firestore.collection('users').where('username', isEqualTo: identifier).get();
        if (userDoc.docs.isEmpty) {
          _errorMessage = "Tên đăng nhập không tồn tại!";
          notifyListeners();
          return false;
        }
        email = userDoc.docs.first['email'];
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null; // 🌟 Xóa dữ liệu khi đăng xuất
    notifyListeners();
  }
}
