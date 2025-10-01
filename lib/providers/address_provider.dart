import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<AddressModel> _addresses = [];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<AddressModel> get addresses => [..._addresses];

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("addresses")
        .get();

    _addresses.clear();
    for (var doc in snapshot.docs) {
      _addresses.add(AddressModel.fromFirestore(doc));
    }
    notifyListeners();
  }

  Future<void> addAddress(AddressModel address) async {
    final user = _auth.currentUser;
    if (user == null) {
      print("❌ No user logged in. Cannot add address.");
      return;
    }

    try {
      print("➡️ Adding address for user: ${user.uid}");
      print("➡️ Data: ${address.toMap()}");

      if (address.isDefault) {
        final existing = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("addresses")
            .get();
        for (var doc in existing.docs) {
          await doc.reference.update({"isDefault": false});
        }
      }

      // ✅ Use doc() + set() instead of add() so we control the ID
      final docRef = _firestore
          .collection("users")
          .doc(user.uid)
          .collection("addresses")
          .doc(); // auto ID

      final addressWithId = address.copyWith(id: docRef.id);

      await docRef.set(addressWithId.toMap());

      print("✅ Address saved with ID: ${docRef.id}");

      _addresses.add(addressWithId);
      notifyListeners();
    } catch (e, st) {
      print("❌ Failed to save address: $e");
      print(st);
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("addresses")
        .doc(id)
        .delete();

    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> updateAddress(AddressModel updated) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // If default → reset others
    if (updated.isDefault) {
      final existing = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("addresses")
          .get();
      for (var doc in existing.docs) {
        await doc.reference.update({"isDefault": false});
      }
    }

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("addresses")
        .doc(updated.id)
        .update(updated.toMap());

    final idx = _addresses.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _addresses[idx] = updated;
    notifyListeners();
  }
}
