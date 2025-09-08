import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart'; // adjust import path
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get getUser {
    return _user;
  }

  bool get isLoggedIn {
    return _user != null;
  }

  String get role {
    return _user?.role ?? 'guest';
  }



  Future<void> fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        _user = UserModel.fromDocument(
          currentUser.uid,
          docSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        // fallback: build user only with FirebaseAuth if Firestore doc missing
        _user = UserModel(
          uid: currentUser.uid,
          username: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          role: 'user', userCart: [], userWish: [], userImage: '', createdAt: Timestamp.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user: $e");
      rethrow;
    }
  }


  Future<String?> login(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await fetchUser(); // fetch Firestore user after login
    return null; // success, no error message
  } on FirebaseAuthException catch (e) {
    return e.message ?? "Login failed";
  } catch (e) {
    return e.toString();
  }
}
void setUser(UserModel user) {
  _user = user;
  notifyListeners();
}


  void clearUser() {
    _user = null;
    notifyListeners();
  }




  bool get isAdmin => _user?.role == 'admin';
  bool get isRegularUser => _user?.role == 'user';
}
