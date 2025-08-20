class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;

  UserModel({
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
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role, 'username': username};
  }
}
