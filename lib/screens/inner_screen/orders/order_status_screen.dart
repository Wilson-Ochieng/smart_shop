import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _loadOrder();
    _startListening();
  }
  
  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _loadOrder() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Try to get order from provider first
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final order = await ordersProvider.getOrderById(widget.orderId);
      
      if (order != null) {
        _order = order;
      } else {
        // If not in provider, fetch from Firestore directly
        final doc = await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .get();
        
        if (doc.exists) {
          _order = OrderModel.fromDocument(doc);
        }
      }
    } catch (error) {
      debugPrint('Error loading order: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _startListening() {
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _order = OrderModel.fromDocument(snapshot);
        });
        
        // Show status updates
        _showStatusUpdate(_order!);
      }
    });
  }
  
  void _showStatusUpdate(OrderModel order) {
    final mpesaStatus = order.mpesaStatus;
    
    // Only show toast for important status changes
    if (mpesaStatus == 'paid') {
      Fluttertoast.showToast(
        msg: '✅ Payment confirmed! Receipt: ${order.mpesaReceiptNumber ?? "N/A"}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else if (mpesaStatus == 'cancelled') {
      Fluttertoast.showToast(
        msg: '❌ Payment was cancelled',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (mpesaStatus == 'failed') {
      Fluttertoast.showToast(
        msg: '⚠️ Payment failed: ${order.mpesaResponse ?? "Unknown error"}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }
  
  Future<void> _refreshOrder() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadOrder();
    
    setState(() {
      _isRefreshing = false;
    });
    
    Fluttertoast.showToast(
      msg: 'Order status refreshed',
      toastLength: Toast.LENGTH_SHORT,
    );
  }
  
  Future<void> _checkPaymentStatus() async {
    try {
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final result = await ordersProvider.checkPaymentStatus(
        orderId: widget.orderId,
        checkoutRequestId: widget.checkoutRequestId,
      );
      
      if (result.containsKey('error')) {
        Fluttertoast.showToast(
          msg: 'Error: ${result['error']}',
          backgroundColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Status: ${result['mpesaStatus']}',
          backgroundColor: Colors.green,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to check status: $error',
        backgroundColor: Colors.red,
      );
    }
  }
  
  String _getStatusIcon(String status) {
    switch (status) {
      case 'paid':
        return '✅';
      case 'cancelled':
        return '❌';
      case 'failed':
        return '⚠️';
      case 'stk_sent':
      case 'stk_push_initiated':
        return '📱';
      case 'initiating':
        return '🔄';
      case 'timeout':
        return '⏰';
      default:
        return '⏳';
    }
  }
  
  String _getStatusMessage(String status, String? response) {
    switch (status) {
      case 'paid':
        return 'Payment Successful!';
      case 'cancelled':
        return 'Payment Cancelled';
      case 'failed':
        return 'Payment Failed';
      case 'stk_sent':
      case 'stk_push_initiated':
        return 'M-Pesa Prompt Sent';
      case 'initiating':
        return 'Initiating Payment';
      case 'timeout':
        return 'Payment Timeout';
      default:
        return 'Waiting for Payment';
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'failed':
        return Colors.orange;
      case 'stk_sent':
      case 'stk_push_initiated':
        return Colors.blue;
      case 'timeout':
        return Colors.amber;
      default:
        return Colors.grey;
    }
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getStatusColor(order.mpesaStatus).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getStatusIcon(order.mpesaStatus),
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Status Text
            Text(
              _getStatusMessage(order.mpesaStatus, order.mpesaResponse),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order.mpesaStatus),
              ),
            ),
            
            SizedBox(height: 10),
            
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
                  _buildDetailRow('Response', order.mpesaResponse!),
                SizedBox(height: 10),
                _buildDetailRow('Order Date', 
                  '${order.createdAt.toDate().hour}:${order.createdAt.toDate().minute} '
                  '${order.createdAt.toDate().day}/${order.createdAt.toDate().month}/${order.createdAt.toDate().year}'
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
  
  Widget _buildOrderItems() {
    if (_order == null || _order!.products.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ..._order!.products.map((product) {
              final price = double.parse(product['price']?.toString() ?? '0');
              final quantity = int.parse(product['quantity']?.toString() ?? '1');
              final total = price * quantity;
              
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['image'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.shopping_bag, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? 'Unknown Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Qty: ${product['quantity']} × Ksh ${price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Item Total
                    Text(
                      'Ksh ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    if (_order == null) return SizedBox.shrink();
    
    final order = _order!;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _checkPaymentStatus,
                icon: Icon(Icons.refresh),
                label: Text('Check Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: Icon(Icons.home),
                label: Text('Go Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 10),
        
        if (order.mpesaStatus == 'paid')
          ElevatedButton(
            onPressed: () {
              // Navigate to order details or download receipt
              Fluttertoast.showToast(
                msg: 'Receipt: ${order.mpesaReceiptNumber ?? "N/A"}',
                toastLength: Toast.LENGTH_LONG,
              );
            },
            child: Text('View Receipt Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        
        if (order.mpesaStatus == 'cancelled' || order.mpesaStatus == 'failed' || order.mpesaStatus == 'timeout')
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _refreshOrder,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshOrder,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    
                    SizedBox(height: 20),
                    
                    // Order Items
                    _buildOrderItems(),
                    
                    SizedBox(height: 20),
                    
                    // Instructions based on status
                    if (_order != null && _order!.mpesaStatus == 'stk_sent')
                      Card(
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
                              SizedBox(height: 8),
                              Text(
                                '1. Check your phone for M-Pesa prompt\n'
                                '2. Enter your M-Pesa PIN when prompted\n'
                                '3. Wait for payment confirmation\n'
                                '4. This page will update automatically',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 20),
                    
                    // Action Buttons
                    _buildActionButtons(),
                    
                    SizedBox(height: 20),
                    
                    // Last Updated
                    if (_order != null)
                      Text(
                        'Last updated: ${_order!.updatedAt.toDate().hour}:${_order!.updatedAt.toDate().minute}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}