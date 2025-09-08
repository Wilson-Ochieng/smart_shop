import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String userImage;
  final Timestamp createdAt;
  final List userCart, userWish;
  final String role;

  UserModel({
    required this.userCart,
    required this.userWish,
    required this.userImage,
    required this.createdAt,
    required this.uid,
    required this.email,
    required this.role,
    required this.username,
  });

  factory UserModel.fromDocument(String uid, Map<String, dynamic> doc) {
    return UserModel(
      uid: uid,
      username: doc['username'],
      email: doc['email'] ?? '',
      role: doc['role'] ?? 'user',
      userImage: doc['userImage'] ?? '',
      createdAt: doc['createdAt'] ?? Timestamp.now(),
      userCart: doc['userCart'] ?? [],
      userWish: doc['userWish'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role, 'username': username};
  }
}
