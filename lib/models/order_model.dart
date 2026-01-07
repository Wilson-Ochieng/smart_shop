import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<Map<String, dynamic>> products;
  final double totalAmount;
  final String status; // Order status: pending, paid, cancelled, failed
  final String mpesaStatus; // M-Pesa status: pending, stk_push_initiated, paid, cancelled, failed, timeout
  final String? mpesaResponse;
  final String? mpesaReceiptNumber;
  final String? checkoutRequestId;
  final String? merchantRequestId;
  final String? customerPhone;
  final String? error;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.mpesaStatus,
    this.mpesaResponse,
    this.mpesaReceiptNumber,
    this.checkoutRequestId,
    this.merchantRequestId,
    this.customerPhone,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'products': products,
      'totalAmount': totalAmount,
      'status': status,
      'mpesaStatus': mpesaStatus,
      'mpesaResponse': mpesaResponse,
      'mpesaReceiptNumber': mpesaReceiptNumber,
      'checkoutRequestId': checkoutRequestId,
      'merchantRequestId': merchantRequestId,
      'customerPhone': customerPhone,
      'error': error,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: data['orderId'] ?? doc.id,
      userId: data['userId'] ?? '',
      products: List<Map<String, dynamic>>.from(data['products'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      mpesaStatus: data['mpesaStatus'] ?? 'pending',
      mpesaResponse: data['mpesaResponse'],
      mpesaReceiptNumber: data['mpesaReceiptNumber'],
      checkoutRequestId: data['checkoutRequestId'],
      merchantRequestId: data['merchantRequestId'],
      customerPhone: data['customerPhone'],
      error: data['error'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  // Helper getters
  bool get isPaymentSuccessful => mpesaStatus == 'paid';
  bool get isPaymentPending => mpesaStatus == 'pending' || mpesaStatus == 'stk_push_initiated';
  bool get isPaymentFailed => mpesaStatus == 'failed' || mpesaStatus == 'cancelled' || mpesaStatus == 'timeout';
  
  // UI helpers
  String get statusIcon {
    switch (mpesaStatus) {
      case 'paid': return '✅';
      case 'cancelled': return '❌';
      case 'failed': return '⚠️';
      case 'timeout': return '⏰';
      case 'stk_push_initiated': return '📱';
      default: return '⏳';
    }
  }
  
  String get statusText {
    switch (mpesaStatus) {
      case 'paid': return 'Paid';
      case 'cancelled': return 'Cancelled';
      case 'failed': return 'Failed';
      case 'timeout': return 'Timeout';
      case 'stk_push_initiated': return 'Processing Payment';
      default: return 'Pending';
    }
  }

  // Copy with method
  OrderModel copyWith({
    String? orderId,
    String? userId,
    List<Map<String, dynamic>>? products,
    double? totalAmount,
    String? status,
    String? mpesaStatus,
    String? mpesaResponse,
    String? mpesaReceiptNumber,
    String? checkoutRequestId,
    String? merchantRequestId,
    String? customerPhone,
    String? error,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      mpesaStatus: mpesaStatus ?? this.mpesaStatus,
      mpesaResponse: mpesaResponse ?? this.mpesaResponse,
      mpesaReceiptNumber: mpesaReceiptNumber ?? this.mpesaReceiptNumber,
      checkoutRequestId: checkoutRequestId ?? this.checkoutRequestId,
      merchantRequestId: merchantRequestId ?? this.merchantRequestId,
      customerPhone: customerPhone ?? this.customerPhone,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}