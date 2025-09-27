import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
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

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.totalQty,
  });

  /// 🔹 Call Firebase Cloud Function to initiate Mpesa STK Push
  Future<String> _initiateMpesaPayment({
    required double amount,
    required String phone,
    required String orderId,
  }) async {
    debugPrint(
      "📡 Initiating Mpesa STK Push → amount: $amount, phone: $phone, orderId: $orderId",
    );

    try {
      final url = Uri.parse(
        "https://us-central1-dukaletu2-66d0b.cloudfunctions.net/api/initiate-stk-push",
      );
      final body = {
        "phone": phone, 
        "amount": amount.toStringAsFixed(0),
        "accountReference": orderId,
        "orderId": orderId,
      };

      debugPrint("📨 Sending POST → $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("📨 Mpesa API raw response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ResponseCode'] == '0') {
          debugPrint("✅ Mpesa STK Push initiated successfully");
          return data['CheckoutRequestID'] ?? 'unknown';
        } else {
          throw Exception("Mpesa API Error: ${data['ResponseDescription']}");
        }
      } else {
        debugPrint(
          "❌ Mpesa Request Failed → Code: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e, stack) {
      debugPrint("🔥 Mpesa Error: $e");
      debugPrint("🪵 Stacktrace: $stack");
      rethrow;
    }
  }

  /// 🔹 Place order and initiate Mpesa Payment
  Future<void> _placeOrder({
    required BuildContext context,
    required CartProvider cartProvider,
    required ProductsProvider productsProvider,
    required UserProvider userProvider,
  }) async {
    debugPrint("🛒 Starting order placement...");
    String? orderId;

    try {
      final user = userProvider.getUser;
      if (user == null) throw Exception("User not logged in");

      debugPrint("👤 Current user: ${user.uid}");

      orderId = const Uuid().v4();
      debugPrint("🆔 Generated Order ID: $orderId");

      // Prepare products
      final products = cartProvider.getCartItems.values.map((cartItem) {
        final product = productsProvider.findByProdId(cartItem.productId);
        if (product == null)
          throw Exception("Product ${cartItem.productId} not found");

        return {
          'productId': cartItem.productId,
          'title': product.productTitle,
          'price': product.productPrice,
          'quantity': cartItem.quantity,
          'image': product.productImage,
        };
      }).toList();

      final total = cartProvider.getTotal(productsProvider: productsProvider);
      debugPrint("💰 Cart Total: $total");

      if (total <= 0) throw Exception("Invalid total amount: $total");

      // 🔹 fallback phone
      const fallbackPhone = "254702430127";

      // STEP 1: Save order PENDING
      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'products': products,
        'totalAmount': total,
        'status': 'pending',
        'mpesaStatus': 'initiating',
        'customerPhone': fallbackPhone,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      debugPrint("📝 Saving order to Firestore → $orderData");

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);
      debugPrint("✅ Order $orderId saved successfully");

      // STEP 2: Initiate Mpesa STK Push
      debugPrint("🚀 Sending STK Push to Cloud Function...");
      final checkoutRequestId = await _initiateMpesaPayment(
        amount: total,
        phone: fallbackPhone,
        orderId: orderId,
      );

      // STEP 3: Update order with Mpesa tracking
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'mpesaStatus': 'stk_sent',
            'checkoutRequestId': checkoutRequestId,
            'updatedAt': Timestamp.now(),
          });

      debugPrint("✅ Updated order with CheckoutRequestID: $checkoutRequestId");

      // STEP 4: Clear cart
      cartProvider.clearLocalCart();
      debugPrint("🧹 Local cart cleared");

      Fluttertoast.showToast(
        msg: "Order placed! Check your phone for Mpesa prompt 📱",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pop(context);
    } catch (e, stack) {
      debugPrint("🔥 Failed to place order: $e");
      debugPrint("🪵 Stacktrace: $stack");

      if (orderId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({
                'status': 'failed',
                'mpesaStatus': 'failed',
                'error': e.toString(),
                'updatedAt': Timestamp.now(),
              });
          debugPrint("📝 Order $orderId marked FAILED");
        } catch (updateError) {
          debugPrint("❌ Failed to update order status: $updateError");
        }
      }

      Fluttertoast.showToast(
        msg: "Order failed: ${e.toString().replaceAll('Exception: ', '')}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final total = cartProvider.getTotal(productsProvider: productsProvider);
    final itemCount = cartProvider.getCartItems.length;

    debugPrint(
      "📊 Rendering OrderSummaryScreen - Total: $total, Items: $itemCount",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (ctx, index) {
                final item = cartProvider.getCartItems.values.toList()[index];
                final product = productsProvider.findByProdId(item.productId);

                if (product == null) {
                  return ListTile(
                    title: Text("Product not found: ${item.productId}"),
                    trailing: const Icon(Icons.error, color: Colors.red),
                  );
                }

                final itemTotal =
                    double.parse(product.productPrice) * item.quantity;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      product.productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.shopping_bag, size: 40),
                    ),
                    title: Text(
                      product.productTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Qty: ${item.quantity} × Ksh ${product.productPrice}",
                    ),
                    trailing: Text(
                      "Ksh ${itemTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Ksh ${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint("💳 Pay with Mpesa button clicked");
                      _placeOrder(
                        context: context,
                        cartProvider: cartProvider,
                        productsProvider: productsProvider,
                        userProvider: userProvider,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Pay with Mpesa"),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You will receive an Mpesa prompt on your phone",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
