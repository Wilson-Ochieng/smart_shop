import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_smart/models/order_model.dart';

class OrdersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _ordersSubscription;

  // Initialize - fetch orders and start listening
  Future<void> initialize() async {
    await fetchUserOrders();
    startListeningToOrders();
  }

  // Fetch user orders from Firestore
  Future<void> fetchUserOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _orders = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => OrderModel.fromDocument(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching orders: $error');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start listening to real-time order updates
  void startListeningToOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _ordersSubscription?.cancel();

    _ordersSubscription = _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _orders = snapshot.docs
              .map((doc) => OrderModel.fromDocument(doc))
              .toList();
          notifyListeners();
        });
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromDocument(doc);
      }
      return null;
    } catch (error) {
      debugPrint('Error getting order: $error');
      return null;
    }
  }

  // Listen to specific order updates
  Stream<OrderModel?> listenToOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return OrderModel.fromDocument(snapshot);
      }
      return null;
    });
  }

  // Create a new order (called from OrderSummaryScreen)
  // Create a new order (called from OrderSummaryScreen)
  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> products,
    required double totalAmount,
    required String phoneNumber,
    required BuildContext context,
  }) async {
    debugPrint('🛒 Starting order creation...');
    debugPrint('📦 Products count: ${products.length}');

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ User not logged in');
        throw Exception('User not logged in');
      }

      // Generate order ID
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('🆔 Generated Order ID: $orderId');

      // Create order data
      final orderData = {
        'orderId': orderId,
        'userId': userId,
        'products': products,
        'totalAmount': totalAmount,
        'status': 'pending',
        'mpesaStatus': 'pending',
        'customerPhone': phoneNumber,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Save to Firestore
      debugPrint('💾 Saving order to Firestore...');
      await _firestore.collection('orders').doc(orderId).set(orderData);
      debugPrint('✅ Order saved to Firestore');

      String checkoutRequestId;
      String mpesaStatus;
      String message;

      try {
        // Try to initiate M-Pesa payment
        debugPrint('📱 Initiating M-Pesa payment...');
        checkoutRequestId = await _initiateMpesaPayment(
          orderId: orderId,
          phone: phoneNumber,
          amount: totalAmount,
        );

        mpesaStatus = 'stk_push_initiated';
        message =
            'Order placed successfully. Check your phone for M-Pesa prompt.';

        debugPrint('✅ M-Pesa initiated successfully');
      } catch (mpesaError) {
        debugPrint('⚠️ M-Pesa initiation failed: $mpesaError');

        // Fallback
        checkoutRequestId = 'manual_${orderId}';
        mpesaStatus = 'manual_payment_pending';
        message =
            'Order placed. M-Pesa service temporarily unavailable. Please make manual payment.';

        debugPrint('⚠️ Using manual fallback');
      }

      // Update order with checkoutRequestId
      debugPrint('🔄 Updating order with payment info...');
      await _firestore.collection('orders').doc(orderId).update({
        'checkoutRequestId': checkoutRequestId,
        'mpesaStatus': mpesaStatus,
        'updatedAt': Timestamp.now(),
      });

      debugPrint('✅ Order updated with payment info');

      // IMPORTANT: DO NOT CLEAR CART HERE
      debugPrint('🛒 Cart preserved - waiting for payment confirmation');

      // Update local list in OrdersProvider (not cart)
      final newOrder = OrderModel(
        orderId: orderId,
        userId: userId,
        products: products,
        totalAmount: totalAmount,
        status: 'pending',
        mpesaStatus: mpesaStatus,
        customerPhone: phoneNumber,
        checkoutRequestId: checkoutRequestId,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      _orders.insert(0, newOrder);
      notifyListeners();

      debugPrint('🎉 Order creation completed successfully');
      debugPrint(
        '📤 Returning result: orderId=$orderId, checkoutRequestId=$checkoutRequestId',
      );

      return {
        'success': true,
        'orderId': orderId,
        'checkoutRequestId': checkoutRequestId,
        'message': message,
      };
    } catch (error, stack) {
      debugPrint('🔥 Error creating order: $error');
      debugPrint('🪵 Stacktrace: $stack');

      return {'success': false, 'error': error.toString()};
    }
  }

  // Initiate M-Pesa payment
  Future<String> _initiateMpesaPayment({
    required String orderId,
    required String phone,
    required double amount,
  }) async {
    try {
      debugPrint('Initiating M-Pesa payment for order: $orderId');

      final url = Uri.parse(
        'https://us-central1-dukaletu2-66d0b.cloudfunctions.net/api/initiate-stk-push',
      );

      // Format phone number
      String formattedPhone = phone;
      if (!phone.startsWith('254')) {
        if (phone.startsWith('0')) {
          formattedPhone = '254${phone.substring(1)}';
        } else if (phone.startsWith('+254')) {
          formattedPhone = phone.substring(1);
        } else {
          formattedPhone = '254$phone';
        }
      }

      debugPrint('📡 Phone (formatted): $formattedPhone');
      debugPrint('💰 Amount: $amount');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone': formattedPhone,
              'amount': amount.toStringAsFixed(0),
              'orderId': orderId,
            }),
          )
          .timeout(Duration(seconds: 30));

      debugPrint('📨 Response Status: ${response.statusCode}');
      debugPrint('📨 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different response formats
        final responseCode =
            data['ResponseCode']?.toString() ??
            data['responseCode']?.toString();

        debugPrint('🔍 Response Code: $responseCode');

        if (responseCode == '0') {
          // Get checkout request ID from various possible fields
          final checkoutRequestId =
              data['CheckoutRequestID']?.toString() ??
              data['checkoutRequestID']?.toString() ??
              data['CheckoutRequestId']?.toString() ??
              data['checkoutRequestId']?.toString();

          if (checkoutRequestId != null && checkoutRequestId.isNotEmpty) {
            debugPrint('✅ M-Pesa payment initiated successfully');
            debugPrint('✅ CheckoutRequestID: $checkoutRequestId');
            return checkoutRequestId;
          } else {
            throw Exception('No CheckoutRequestID received from M-Pesa API');
          }
        } else {
          final errorDesc =
              data['ResponseDescription'] ??
              data['errorMessage'] ??
              data['error'] ??
              'Unknown M-Pesa error';
          throw Exception('M-Pesa API Error: $errorDesc');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      debugPrint('⏰ M-Pesa request timed out');
      throw Exception('Payment service timeout. Please try again.');
    } on http.ClientException catch (e) {
      debugPrint('🌐 Network error: $e');
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      debugPrint('🔥 M-Pesa initiation error: $e');
      debugPrint('🪵 Stacktrace: $stack');
      rethrow;
    }
  }

  // Check payment status from backend
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String orderId,
    String? checkoutRequestId,
  }) async {
    try {
      final url = Uri.parse(
        'https://us-central1-dukaletu2-66d0b.cloudfunctions.net/api/check-payment',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'checkoutRequestId': checkoutRequestId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check payment status');
      }
    } catch (error) {
      debugPrint('Check payment error: $error');
      return {'error': error.toString()};
    }
  }

  // Mark order as paid (for testing or manual override)
  Future<bool> markOrderAsPaid(String orderId, String receiptNumber) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'paid',
        'mpesaStatus': 'paid',
        'mpesaResponse': 'Payment successful',
        'mpesaReceiptNumber': receiptNumber,
        'updatedAt': Timestamp.now(),
      });

      // Update local list
      final index = _orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: 'paid',
          mpesaStatus: 'paid',
          mpesaResponse: 'Payment successful',
          mpesaReceiptNumber: receiptNumber,
        );
        notifyListeners();
      }

      return true;
    } catch (error) {
      debugPrint('Error marking order as paid: $error');
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'mpesaStatus': 'cancelled',
        'mpesaResponse': 'Cancelled by user',
        'updatedAt': Timestamp.now(),
      });

      // Update local list
      final index = _orders.indexWhere((order) => order.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: 'cancelled',
          mpesaStatus: 'cancelled',
          mpesaResponse: 'Cancelled by user',
        );
        notifyListeners();
      }

      return true;
    } catch (error) {
      debugPrint('Error cancelling order: $error');
      return false;
    }
  }

  // Filter orders
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<OrderModel> getOrdersByMpesaStatus(String mpesaStatus) {
    return _orders.where((order) => order.mpesaStatus == mpesaStatus).toList();
  }

  List<OrderModel> get pendingOrders => getOrdersByStatus('pending');
  List<OrderModel> get paidOrders => getOrdersByStatus('paid');
  List<OrderModel> get cancelledOrders => getOrdersByStatus('cancelled');

  // Calculate total spent
  double get totalSpent {
    return _orders
        .where((order) => order.isPaymentSuccessful)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Clear orders (logout)
  void clearOrders() {
    _orders = [];
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
