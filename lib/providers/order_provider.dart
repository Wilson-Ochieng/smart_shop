import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<Map<String, dynamic>> products;
  final double totalAmount;
  final String status; // pending, shipped, delivered, cancelled
  final Timestamp createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'products': products,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory OrderModel.fromDocument(Map<String, dynamic> doc) {
    return OrderModel(
      orderId: doc['orderId'],
      userId: doc['userId'],
      products: List<Map<String, dynamic>>.from(doc['products']),
      totalAmount: (doc['totalAmount'] ?? 0.0).toDouble(),
      status: doc['status'] ?? 'pending',
      createdAt: doc['createdAt'] ?? Timestamp.now(),
    );
  }
}
