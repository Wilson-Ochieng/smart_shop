import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shop_smart/models/cart_model.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/order_provider.dart'; // Fixed import
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/providers/user_provider.dart';
import 'package:shop_smart/screens/inner_screen/orders/order_status_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
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

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// 🔹 Format phone number to MPesa format (254XXXXXXXXX)
  String _formatPhoneNumber(String phone) {
    String formatted = phone.trim();

    // Remove any spaces or dashes
    formatted = formatted.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if starts with '0' and replace with '254'
    if (formatted.startsWith('0')) {
      formatted = '254${formatted.substring(1)}';
    }
    // Check if starts with '+254' and remove '+'
    else if (formatted.startsWith('+254')) {
      formatted = formatted.substring(1);
    }
    // Check if starts with '254' already
    else if (!formatted.startsWith('254')) {
      formatted = '254$formatted';
    }

    // Validate final format
    if (formatted.length != 12) {
      throw Exception('Invalid phone number format. Expected: 254XXXXXXXXX');
    }

    return formatted;
  }

  /// 🔹 Validate phone number
  bool _validatePhoneNumber(String phone) {
    // Basic validation for Kenyan numbers
    final pattern = RegExp(r'^(0|\+?254)[1-9]\d{8}$');
    return pattern.hasMatch(phone);
  }

  /// 🔹 Place order using OrdersProvider
  Future<void> _placeOrder({
    required BuildContext context,
    required CartProvider cartProvider,
    required ProductsProvider productsProvider,
    required UserProvider userProvider,
  }) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    debugPrint("🛒 Starting order placement...");

    try {
      final user = userProvider.getUser;
      if (user == null) throw Exception("User not logged in");

      debugPrint("👤 Current user: ${user.uid}");

      final phone = _phoneController.text.trim();

      // Validate phone number format
      if (!_validatePhoneNumber(phone)) {
        throw Exception(
          'Please enter a valid Kenyan phone number (e.g., 0712345678 or 254712345678)',
        );
      }

      // Prepare products list
      final products = cartProvider.getCartItems.values.map((cartItem) {
        final product = productsProvider.findByProdId(cartItem.productId);
        if (product == null) {
          throw Exception("Product ${cartItem.productId} not found");
        }

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

      // Get OrdersProvider
      final ordersProvider = Provider.of<OrdersProvider>(
        context,
        listen: false,
      );

      // Create order using OrdersProvider
      debugPrint("📝 Creating order via OrdersProvider...");
      final result = await ordersProvider.createOrder(
        products: products,
        totalAmount: total,
        phoneNumber: phone,
        context: context,
      );

      debugPrint("📊 OrdersProvider Result: $result");

      if (result['success'] == true) {
        // Clear cart
        cartProvider.clearLocalCart();
        debugPrint("✅ Order created: ${result['orderId']}");
        debugPrint("✅ CheckoutRequestId: ${result['checkoutRequestId']}");

        // Show success message
        Fluttertoast.showToast(
          msg: "Order placed! Check your phone for M-Pesa prompt 📱",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
        );

        // Navigate to order status screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => OrderStatusScreen(
              orderId: result['orderId'],
              checkoutRequestId: result['checkoutRequestId'],
            ),
          ),
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to create order');
      }
    } catch (e, stack) {
      debugPrint("🔥 Failed to place order: $e");
      debugPrint("🪵 Stacktrace: $stack");

      Fluttertoast.showToast(
        msg: "Order failed: ${e.toString().replaceAll('Exception: ', '')}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order Items List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (ctx, index) {
                    final item = cartProvider.getCartItems.values
                        .toList()[index];
                    final product = productsProvider.findByProdId(
                      item.productId,
                    );

                    if (product == null) {
                      return ListTile(
                        title: Text("Product not found: ${item.productId}"),
                        trailing: const Icon(Icons.error, color: Colors.red),
                      );
                    }

                    final itemTotal =
                        double.parse(product.productPrice) * item.quantity;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
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

                const SizedBox(height: 20),

                // Phone Number Input
                Form(
                  key: _formKey,
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Enter Your M-Pesa Phone Number",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "You will receive an M-Pesa prompt on this number to complete payment",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              hintText: "0712345678 or 254712345678",
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!_validatePhoneNumber(value.trim())) {
                                return 'Please enter a valid Kenyan phone number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Auto-format as user types
                              if (value.length == 1 &&
                                  value != '0' &&
                                  value != '+') {
                                _phoneController.text = '0$value';
                                _phoneController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _phoneController.text.length,
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Format: 0712345678 or 254712345678",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Add a test button for debugging
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          "Debug Tools",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final testPhone = "254708374149";
                                  debugPrint(
                                    "🧪 Testing phone formatting: $testPhone",
                                  );
                                  final formatted = _formatPhoneNumber(
                                    testPhone,
                                  );
                                  debugPrint("🧪 Formatted: $formatted");
                                  Fluttertoast.showToast(
                                    msg: "Test: $testPhone → $formatted",
                                  );
                                } catch (e) {
                                  debugPrint("🧪 Test error: $e");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Test Format"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final url = Uri.parse(
                                    'https://us-central1-dukaletu2-66d0b.cloudfunctions.net/api/health',
                                  );
                                  final response = await http.get(url);
                                  debugPrint(
                                    '🧪 Health Check: ${response.statusCode} - ${response.body}',
                                  );
                                  Fluttertoast.showToast(
                                    msg: "Health: ${response.statusCode}",
                                  );
                                } catch (e) {
                                  debugPrint('🧪 Health error: $e');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Test API"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payment Summary & Button
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
                  child: _isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (itemCount == 0) {
                              Fluttertoast.showToast(
                                msg: "Your cart is empty",
                                backgroundColor: Colors.orange,
                              );
                              return;
                            }
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
