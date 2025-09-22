import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/models/cart_model.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/providers/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSummaryScreen extends StatelessWidget {
  static const routName = "/OrderSummaryScreen";

  final Map<String, CartModel> cartItems;
  final String totalPrice;
  final int totalQty;
  const OrderSummaryScreen({super.key, required this.cartItems, required this.totalPrice, required this.totalQty});


  Future<void> _initiateMpesaPayment({
    required double amount,
    required String phone,
  }) async {
    // This is where you call your Mpesa Daraja API
    // For now we simulate success
    print("Initiating Mpesa STK Push for Ksh $amount to $phone ...");

    await Future.delayed(const Duration(seconds: 3)); // simulate request
    print("Mpesa Payment Successful ✅");
  }

  Future<void> _placeOrder({
    required BuildContext context,
    required CartProvider cartProvider,
    required ProductsProvider productsProvider,
    required UserProvider userProvider,
  }) async {
    try {
      final user = userProvider.getUser;
      final orderId = const Uuid().v4();

      final products = cartProvider.getCartItems.values.map((cartItem) {
        final product = productsProvider.findByProdId(cartItem.productId);
        return {
          'productId': cartItem.productId,
          'title': product?.productTitle,
          'price': product?.productPrice,
          'quantity': cartItem.quantity,
          'image': product?.productImage,
        };
      }).toList();

      final total = cartProvider.getTotal(productsProvider: productsProvider);

      // 🔹 Initiate Mpesa
      await _initiateMpesaPayment(
        amount: total,
        phone: user!.email, // TODO: replace with user phone
      );

      // 🔹 Save to Firestore only after successful payment
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': user.uid,
        'products': products,
        'totalAmount': total,
        'status': 'paid',
        'createdAt': Timestamp.now(),
      });

      cartProvider.clearLocalCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );

      Navigator.pop(context); // Go back to previous screen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final total = cartProvider.getTotal(productsProvider: productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.getCartItems.length,
              itemBuilder: (ctx, index) {
                final item = cartProvider.getCartItems.values.toList()[index];
                final product = productsProvider.findByProdId(item.productId);

                return ListTile(
                  leading: Image.network(product!.productImage, width: 50),
                  title: Text(product.productTitle),
                  subtitle: Text(
                    "Qty: ${item.quantity} • Ksh ${product.productPrice}",
                  ),
                  trailing: Text(
                    "Ksh ${(double.parse(product.productPrice) * item.quantity).toStringAsFixed(2)}",
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: Ksh $total",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _placeOrder(
                      context: context,
                      cartProvider: cartProvider,
                      productsProvider: productsProvider,
                      userProvider: userProvider,
                    );
                  },
                  child: const Text("Pay with Mpesa"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
