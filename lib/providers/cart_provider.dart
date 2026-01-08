import 'package:flutter/material.dart';
import 'package:shop_smart/models/cart_model.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartItems {
    return _cartItems;
  }
  
  // Track if we've recently restored cart to avoid duplicates
  bool _hasRestoredCart = false;
  DateTime? _lastRestoreTime;

  void addProductToCart({required String productId, int quantity = 1}) {
    if (_cartItems.containsKey(productId)) {
      // Update quantity if product already exists
      final existingItem = _cartItems[productId]!;
      _cartItems.update(
        productId,
        (cartitem) => CartModel(
          cartId: cartitem.cartId,
          productId: productId,
          quantity: cartitem.quantity + quantity,
        ),
      );
    } else {
      // Add new product
      _cartItems.putIfAbsent(
        productId,
        () => CartModel(
          cartId: const Uuid().v4(),
          productId: productId,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void updateQty({required String productId, required int qty}) {
    if (qty <= 0) {
      removeOneItem(productId: productId);
      return;
    }
    
    _cartItems.update(
      productId,
      (cartitem) => CartModel(
        cartId: cartitem.cartId,
        productId: productId,
        quantity: qty,
      ),
    );
    notifyListeners();
  }

  bool isProdinCart({required String productId}) {
    return _cartItems.containsKey(productId);
  }

  double getTotal({required ProductsProvider productsProvider}) {
    double total = 0.0;
    _cartItems.forEach((key, value) {
      final getCurrentProduct = productsProvider.findByProdId(value.productId);
      if (getCurrentProduct == null) {
        total += 0;
      } else {
        total += double.parse(getCurrentProduct.productPrice) * value.quantity;
      }
    });

    return total;
  }

  int getQty() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  void clearLocalCart() {
    _cartItems.clear();
    _hasRestoredCart = false;
    notifyListeners();
  }

  void removeOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners();
  }
  
  // NEW: Restore cart from order products
  Future<void> restoreCartFromOrder(List<Map<String, dynamic>> orderProducts) async {
    // Prevent multiple restores within 30 seconds
    if (_hasRestoredCart && 
        _lastRestoreTime != null && 
        DateTime.now().difference(_lastRestoreTime!).inSeconds < 30) {
      debugPrint('🔄 Skipping cart restore - already restored recently');
      return;
    }
    
    try {
      debugPrint('🔄 Starting cart restoration...');
      debugPrint('📦 Products to restore: ${orderProducts.length}');
      
      // Clear cart first if it's not empty
      if (_cartItems.isNotEmpty) {
        debugPrint('🗑️ Clearing existing cart items: ${_cartItems.length}');
        _cartItems.clear();
      }
      
      // Restore all products from the order
      int restoredCount = 0;
      for (final product in orderProducts) {
        final productId = product['productId']?.toString();
        final quantity = int.parse(product['quantity']?.toString() ?? '1');
        
        if (productId != null && productId.isNotEmpty) {
          addProductToCart(
            productId: productId,
            quantity: quantity,
          );
          restoredCount++;
          debugPrint('✅ Restored: $productId x$quantity');
        }
      }
      
      _hasRestoredCart = true;
      _lastRestoreTime = DateTime.now();
      
      debugPrint('🎉 Cart restoration complete! Restored $restoredCount items');
      notifyListeners();
      
    } catch (error) {
      debugPrint('❌ Error restoring cart: $error');
      rethrow;
    }
  }
  
  // NEW: Check if cart is empty (useful for order status screen)
  bool get isCartEmpty => _cartItems.isEmpty;
  
  // NEW: Get cart items count
  int get itemCount => _cartItems.length;
  
  // NEW: Get specific item quantity
  int getItemQuantity(String productId) {
    return _cartItems[productId]?.quantity ?? 0;
  }
  
  // NEW: Reset restore flags (call this on new order creation)
  void resetRestoreFlags() {
    _hasRestoredCart = false;
    _lastRestoreTime = null;
  }
  
  // NEW: Clear specific items (optional)
  void clearSpecificItems(List<String> productIds) {
    for (final productId in productIds) {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }
  
  // NEW: Convert cart to order format
  List<Map<String, dynamic>> toOrderFormat() {
    return _cartItems.values.map((cartItem) {
      return {
        'productId': cartItem.productId,
        'quantity': cartItem.quantity,
        'cartId': cartItem.cartId,
      };
    }).toList();
  }
}