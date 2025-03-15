class UserModel {
  String uid;
  String username;
  String email;
  String? fullname;
  String? phone;
  String? address;
  String? avatarUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.fullname,
    this.phone,
    this.address,
    this.avatarUrl,
  });

  // Chuyển đổi từ object sang Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'fullname': fullname ?? '',
      'phone': phone ?? '',
      'address': address ?? '',
      'avatarUrl': avatarUrl ?? '',
    };
  }

  // Chuyển đổi từ Map (Firebase) thành object UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      fullname: map['fullname'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}
