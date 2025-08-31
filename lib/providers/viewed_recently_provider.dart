import 'package:flutter/material.dart';
import 'package:shop_smart/models/viewed_products.dart';
import 'package:uuid/uuid.dart';

class ViewedProdProvider with ChangeNotifier {
  final Map<String, ViewProdModel> _viewedProdItems = {};
  Map<String, ViewProdModel> get getViewedProds {
    return _viewedProdItems;
  }

  void addViewedProd({required String productId}) {
    _viewedProdItems.putIfAbsent(
      productId,
      () => ViewProdModel(
        viewdrecentlyId: const Uuid().v4(),
        productId: productId,
      ),
    );
  }

  @override
  notifyListeners();


   void clearLocalViewedProd() {
    _viewedProdItems.clear();
    notifyListeners();
  }
}
