import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/models/cart_model.dart';
import '../../../../core/services/firebase_service.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل الطلبات');
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> createOrder({
    required String userId,
    required String userEmail,
    required String userName,
    required List<CartItemModel> items,
    required double subtotal,
    required double tax,
    required double shipping,
    required double total,
    required PaymentMethod paymentMethod,
    String? paymentId,
    required Map<String, dynamic> shippingAddress,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final order = OrderModel(
        id: '', // Will be set by Firestore
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
        shippingAddress: shippingAddress,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await FirebaseService.ordersCollection.add(order.toFirestore());
      
      final createdOrder = order.copyWith();
      _orders.insert(0, OrderModel(
        id: docRef.id,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
        shippingAddress: shippingAddress,
        notes: notes,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      ));

      notifyListeners();
      return createdOrder;
    } catch (e) {
      _setError('فشل إنشاء الطلب');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await FirebaseService.ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('فشل تحميل الطلب');
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await FirebaseService.ordersCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل تحديث حالة الطلب');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      _setError('فشل إلغاء الطلب');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}