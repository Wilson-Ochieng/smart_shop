import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get getProducts => _products;
  bool get isLoading => _isLoading;

  /// Fetch products from Firestore
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('products').get();

      _products = snapshot.docs.map((doc) {
        return ProductModel(
          productId: doc['productId'],
          productTitle: doc['productTitle'],
          productPrice: doc['productPrice'],
          productCategory: doc['productCategory'],
          productDescription: doc['productDescription'],
          productImage: doc['productImage'],
          productQuantity: doc['productQuantity'],
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error fetching products: $e");
    }
  }

  ProductModel? findByProdId(String productId) {
    try {
      return _products.firstWhere((element) => element.productId == productId);
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> findByCategory({required String categoryName}) {
    return _products
        .where(
          (element) => element.productCategory.toLowerCase().contains(
            categoryName.toLowerCase(),
          ),
        )
        .toList();
  }

  List<ProductModel> searchQuery({
    required String searchText,
    required List<ProductModel> passedList,
  }) {
    return passedList
        .where(
          (element) => element.productTitle.toLowerCase().contains(
            searchText.toLowerCase(),
          ),
        )
        .toList();
  }
}
