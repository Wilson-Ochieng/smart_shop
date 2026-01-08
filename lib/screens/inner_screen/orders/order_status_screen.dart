import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/order_provider.dart';
import 'package:shop_smart/models/order_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderStatusScreen extends StatefulWidget {
  static const routeName = '/order-status';
  
  final String orderId;
  final String? checkoutRequestId;
  
  const OrderStatusScreen({
    super.key,
    required this.orderId,
    this.checkoutRequestId,
  });
  
  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  StreamSubscription<DocumentSnapshot>? _orderSubscription;
  OrderModel? _order;
  bool _isLoading = true;
  bool _hasPaymentFailed = false;
  bool _hasPaymentSucceeded = false;
  bool _shouldRestoreCart = false;
  Timer? _statusCheckTimer;
  Timer? _countdownTimer;
  int _secondsElapsed = 0;
  int _maxWaitTime = 180; // 3 minutes
  
  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }
  
  @override
  void dispose() {
    _orderSubscription?.cancel();
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  void _startMonitoring() {
    _loadOrder();
    _startListening();
    _startCountdownTimer();
    _startAutoStatusCheck();
  }
  
  Future<void> _loadOrder() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();
      
      if (doc.exists) {
        final order = OrderModel.fromDocument(doc);
        setState(() {
          _order = order;
          _hasPaymentFailed = _isPaymentFailed(order.mpesaStatus);
          _hasPaymentSucceeded = order.mpesaStatus == 'paid';
        });
        
        // Handle cart based on current status
        if (_hasPaymentSucceeded) {
          await _clearCartOnSuccess();
        } else if (_hasPaymentFailed) {
          await _checkAndHandlePaymentFailure(order);
        }
      } else {
        debugPrint('❌ Order not found: ${widget.orderId}');
      }
    } catch (error) {
      debugPrint('❌ Error loading order: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _startListening() {
    _orderSubscription?.cancel();
    
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        final updatedOrder = OrderModel.fromDocument(snapshot);
        final previousStatus = _order?.mpesaStatus;
        
        setState(() {
          _order = updatedOrder;
          _hasPaymentFailed = _isPaymentFailed(updatedOrder.mpesaStatus);
          _hasPaymentSucceeded = updatedOrder.mpesaStatus == 'paid';
        });
        
        // Check for status change
        if (previousStatus != updatedOrder.mpesaStatus) {
          debugPrint('🔄 Status changed: $previousStatus → ${updatedOrder.mpesaStatus}');
          
          if (updatedOrder.mpesaStatus == 'paid') {
            await _clearCartOnSuccess();
          } else if (_isPaymentFailed(updatedOrder.mpesaStatus)) {
            await _checkAndHandlePaymentFailure(updatedOrder);
          }
        }
        
        // Show status update messages
        _showStatusMessage(updatedOrder);
      }
    }, onError: (error) {
      debugPrint('❌ Order stream error: $error');
    });
  }
  
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _secondsElapsed = 0;
    
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsElapsed >= _maxWaitTime) {
        timer.cancel();
        if (!_hasPaymentFailed && !_hasPaymentSucceeded) {
          _handleTimeout();
        }
        return;
      }
      
      setState(() {
        _secondsElapsed++;
      });
      
      // Every 30 seconds, check if we should refresh
      if (_secondsElapsed % 30 == 0 && !_hasPaymentFailed && !_hasPaymentSucceeded) {
        _refreshOrder();
      }
    });
  }
  
  void _startAutoStatusCheck() {
    _statusCheckTimer?.cancel();
    
    _statusCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_hasPaymentFailed || _hasPaymentSucceeded) {
        timer.cancel();
        return;
      }
      
      // If order is still pending after 30 seconds, try checking status
      if (_secondsElapsed > 30 && 
          _order != null && 
          _order!.mpesaStatus == 'pending') {
        await _checkPaymentStatus();
      }
    });
  }
  
  bool _isPaymentFailed(String status) {
    return status == 'failed' || 
           status == 'cancelled' || 
           status == 'timeout' ||
           status == 'payment_failed';
  }
  
  Future<void> _checkAndHandlePaymentFailure(OrderModel order) async {
    if (_isPaymentFailed(order.mpesaStatus) && !_shouldRestoreCart && !_hasPaymentSucceeded) {
      _shouldRestoreCart = true;
      
      // Clear timers
      _statusCheckTimer?.cancel();
      _countdownTimer?.cancel();
      
      // Show failure message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDetailedFailureMessage(order);
      });
      
      // Wait a moment then try to restore cart
      await Future.delayed(Duration(seconds: 2));
      await _restoreCartIfNeeded(order);
    }
  }
  
  Future<void> _clearCartOnSuccess() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Check if cart has items to clear
      if (cartProvider.getCartItems.isNotEmpty) {
        debugPrint('🗑️ Clearing cart on successful payment...');
        debugPrint('📦 Items in cart before clearing: ${cartProvider.getCartItems.length}');
        
        // Clear the cart
        cartProvider.clearLocalCart();
        
        debugPrint('✅ Cart cleared successfully');
        
        // Show confirmation message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Fluttertoast.showToast(
            msg: 'Cart cleared - Payment successful!',
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.green,
          );
        });
      } else {
        debugPrint('🛒 Cart already empty');
      }
    } catch (error) {
      debugPrint('❌ Error clearing cart on success: $error');
    }
  }
  
  Future<void> _restoreCartIfNeeded(OrderModel order) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Check if cart is already restored or order is paid
      if (_hasPaymentFailed && !_hasPaymentSucceeded) {
        await cartProvider.restoreCartFromOrder(order.products);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Fluttertoast.showToast(
            msg: 'Items restored to cart',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
        });
      }
    } catch (error) {
      debugPrint('❌ Error restoring cart: $error');
    }
  }
  
  void _handleTimeout() {
    if (!_hasPaymentFailed && !_hasPaymentSucceeded) {
      setState(() {
        _hasPaymentFailed = true;
        _shouldRestoreCart = true;
      });
      
      // Update Firestore with timeout status
      FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'mpesaStatus': 'timeout',
            'mpesaResponse': 'Payment timeout - no response received within $_maxWaitTime seconds',
            'updatedAt': Timestamp.now(),
          })
          .catchError((error) {
            debugPrint('❌ Error updating timeout status: $error');
          });
      
      _showDetailedFailureMessage(OrderModel(
        orderId: widget.orderId,
        userId: _order?.userId ?? '',
        products: _order?.products ?? [],
        totalAmount: _order?.totalAmount ?? 0,
        status: 'failed',
        mpesaStatus: 'timeout',
        mpesaResponse: 'Payment timeout - no response received within $_maxWaitTime seconds',
        createdAt: _order?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      ));
      
      // Restore cart after timeout
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(seconds: 1));
        if (_order != null) {
          await _restoreCartIfNeeded(_order!);
        }
      });
    }
  }
  
  Future<void> _checkPaymentStatus() async {
    try {
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final result = await ordersProvider.checkPaymentStatus(
        orderId: widget.orderId,
        checkoutRequestId: widget.checkoutRequestId,
      );
      
      if (result.containsKey('error')) {
        debugPrint('❌ Status check error: ${result['error']}');
      } else {
        debugPrint('✅ Status check result: ${result['mpesaStatus']}');
      }
    } catch (error) {
      debugPrint('❌ Failed to check status: $error');
    }
  }
  
  Future<void> _refreshOrder() async {
    try {
      await _loadOrder();
    } catch (error) {
      debugPrint('❌ Refresh error: $error');
    }
  }
  
  void _showStatusMessage(OrderModel order) {
    final mpesaStatus = order.mpesaStatus;
    
    if (mpesaStatus == 'paid') {
      Fluttertoast.showToast(
        msg: '✅ Payment confirmed! Receipt: ${order.mpesaReceiptNumber ?? "N/A"}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
      // Stop timers on success
      _statusCheckTimer?.cancel();
      _countdownTimer?.cancel();
    }
  }
  
  void _showDetailedFailureMessage(OrderModel order) {
    String message = '';
    String title = 'Payment Failed';
    
    switch (order.mpesaStatus) {
      case 'cancelled':
        message = 'You cancelled the payment request. Please try again if you wish to complete the purchase.';
        title = 'Payment Cancelled';
        break;
      case 'failed':
        message = 'Payment failed: ${order.mpesaResponse ?? "Insufficient funds or transaction declined"}';
        title = 'Payment Failed';
        break;
      case 'timeout':
        message = 'Payment request timed out. No response received from M-Pesa within $_maxWaitTime seconds.';
        title = 'Payment Timeout';
        break;
      case 'payment_failed':
        message = 'Payment initiation failed: ${order.mpesaResponse ?? "Service temporarily unavailable"}';
        title = 'Payment Service Error';
        break;
      default:
        message = 'Payment failed: ${order.mpesaResponse ?? "Unknown error"}';
    }
    
    // Show detailed dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              SizedBox(height: 10),
              if (order.mpesaResponse != null && 
                  order.mpesaStatus != 'timeout')
                Text(
                  'M-Pesa Response: ${order.mpesaResponse}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              SizedBox(height: 10),
              Text(
                'Note: Your items have been restored to the cart.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Go back to cart
              },
              child: Text('Go Back to Cart'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _retryPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    });
  }
  
  void _retryPayment() {
    // Navigate back to order summary with cart items
    Navigator.of(context).pop();
  }
  
  String _getStatusIcon(String status) {
    switch (status) {
      case 'paid': return '✅';
      case 'cancelled': return '❌';
      case 'failed': return '⚠️';
      case 'stk_sent':
      case 'stk_push_initiated': return '📱';
      case 'initiating': return '🔄';
      case 'pending': return '⏳';
      case 'timeout': return '⏰';
      default: return '⏳';
    }
  }
  
  String _getStatusMessage(String status) {
    switch (status) {
      case 'paid': return 'Payment Successful!';
      case 'cancelled': return 'Payment Cancelled';
      case 'failed': return 'Payment Failed';
      case 'stk_sent':
      case 'stk_push_initiated': return 'M-Pesa Prompt Sent';
      case 'initiating': return 'Initiating Payment';
      case 'pending': return 'Waiting for Payment';
      case 'timeout': return 'Payment Timeout';
      default: return 'Processing Payment';
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'failed': return Colors.orange;
      case 'stk_sent':
      case 'stk_push_initiated': return Colors.blue;
      case 'timeout': return Colors.amber;
      default: return Colors.grey;
    }
  }
  
  Widget _buildCountdownTimer() {
    final remaining = _maxWaitTime - _secondsElapsed;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.blue[700]),
          SizedBox(width: 8),
          Text(
            'Auto-refresh in: $minutes:$seconds',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard() {
    if (_order == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Order not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Order ID: ${widget.orderId}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    final order = _order!;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Status Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getStatusColor(order.mpesaStatus).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getStatusIcon(order.mpesaStatus),
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Status Text
            Text(
              _getStatusMessage(order.mpesaStatus),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order.mpesaStatus),
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 10),
            
            // Countdown Timer
            if (!_hasPaymentFailed && !_hasPaymentSucceeded && order.mpesaStatus != 'paid')
              Column(
                children: [
                  SizedBox(height: 10),
                  _buildCountdownTimer(),
                ],
              ),
            
            SizedBox(height: 20),
            
            // Order ID
            Text(
              'Order #${order.orderId.substring(0, 8)}...',
              style: TextStyle(color: Colors.grey),
            ),
            
            SizedBox(height: 20),
            
            // Status Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow('Total Amount', 'Ksh ${order.totalAmount.toStringAsFixed(2)}'),
                SizedBox(height: 10),
                if (order.customerPhone != null)
                  _buildDetailRow('Phone Number', order.customerPhone!),
                SizedBox(height: 10),
                if (order.mpesaReceiptNumber != null)
                  _buildDetailRow('M-Pesa Receipt', order.mpesaReceiptNumber!),
                SizedBox(height: 10),
                if (order.mpesaResponse != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'M-Pesa Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        order.mpesaResponse!,
                        style: TextStyle(
                          color: _isPaymentFailed(order.mpesaStatus) 
                              ? Colors.red 
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInstructions() {
    if (_hasPaymentFailed || _hasPaymentSucceeded) {
      return SizedBox.shrink();
    }
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Payment Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructionStep('1. Check your phone', 'Look for M-Pesa STK Push prompt'),
                _buildInstructionStep('2. Enter PIN', 'Use your M-Pesa PIN to authorize payment'),
                _buildInstructionStep('3. Wait for confirmation', 'This page updates automatically'),
                _buildInstructionStep('4. Time limit', 'Complete within ${_maxWaitTime ~/ 60} minutes'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstructionStep(String step, String instruction) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.split('.')[0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  instruction,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    if (_order == null) return SizedBox.shrink();
    
    final order = _order!;
    
    if (_hasPaymentSucceeded) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
            label: Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
          SizedBox(height: 10),
          if (order.mpesaReceiptNumber != null)
            TextButton(
              onPressed: () {
                Fluttertoast.showToast(
                  msg: 'Receipt: ${order.mpesaReceiptNumber}',
                  toastLength: Toast.LENGTH_LONG,
                );
              },
              child: Text('View Receipt Details'),
            ),
        ],
      );
    }
    
    if (_hasPaymentFailed) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.shopping_cart),
            label: Text('Go Back to Cart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Note: Your items have been restored to your cart',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return SizedBox.shrink();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasPaymentFailed || _hasPaymentSucceeded) {
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Leave Payment Page?'),
                  content: Text('Your payment is still processing. Leaving may interrupt the process.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Stay'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Leave'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Loading order status...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status Card
                  _buildStatusCard(),
                  
                  SizedBox(height: 20),
                  
                  // Instructions
                  _buildInstructions(),
                  
                  SizedBox(height: 20),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  
                  SizedBox(height: 20),
                  
                  // Last Updated
                  if (_order != null && !_hasPaymentSucceeded && !_hasPaymentFailed)
                    Text(
                      'Monitoring payment...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}