import 'package:flutter/material.dart';
import 'package:shop_smart/models/wishlist_model.dart';
import 'package:uuid/uuid.dart';

class WishlistProvider with ChangeNotifier {
  final Map<String, WishlistModel> _wishListItems = {};
  Map<String, WishlistModel> get getWishlists {
    return _wishListItems;
  }

  void addOrRemoveFromWishList({required String productId}) {
    if (_wishListItems.containsKey(productId)) {
      _wishListItems.remove(productId);
    } else {
      _wishListItems.putIfAbsent(
        productId,
        () =>
            WishlistModel(wishlistId: const Uuid().v4(), productId: productId),
      );
    }

    notifyListeners();
  }

  bool isProdinWishList({required String productId}) {
    return _wishListItems.containsKey(productId);
  }

  void clearLocalWishList() {
    _wishListItems.clear();
    notifyListeners();
  }
}
