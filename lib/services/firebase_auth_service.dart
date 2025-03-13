import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Kiểm tra username đã tồn tại chưa
      var existingUser = await _firestore.collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return 'Tên đăng nhập đã tồn tại!';
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'uid': userCredential.user!.uid,
      });

      return null; // Thành công
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser({required String identifier, required String password}) async {
    try {
      String email = identifier;

      if (!identifier.contains('@')) {
        // Nếu nhập tên đăng nhập, tìm email tương ứng
        var userDoc = await _firestore.collection('users')
            .where('username', isEqualTo: identifier)
            .get();

        if (userDoc.docs.isEmpty) {
          return 'Tên đăng nhập không tồn tại!';
        }

        email = userDoc.docs.first['email'];
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Thành công
    } catch (e) {
      return e.toString();
    }
  }
}
