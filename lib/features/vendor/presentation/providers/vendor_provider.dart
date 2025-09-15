import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/firebase_service.dart';

class VendorProvider extends ChangeNotifier {
  List<ProductModel> _vendorProducts = [];
  List<OrderModel> _vendorOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Analytics data
  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _totalProducts = 0;
  Map<String, double> _monthlyRevenue = {};

  List<ProductModel> get vendorProducts => _vendorProducts;
  List<OrderModel> get vendorOrders => _vendorOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalRevenue => _totalRevenue;
  int get totalOrders => _totalOrders;
  int get totalProducts => _totalProducts;
  Map<String, double> get monthlyRevenue => _monthlyRevenue;

  Future<void> loadVendorData(String vendorId) async {
    try {
      _setLoading(true);
      _clearError();

      await Future.wait([
        _loadVendorProducts(vendorId),
        _loadVendorOrders(vendorId),
      ]);

      _calculateAnalytics();
      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل بيانات البائع');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadVendorProducts(String vendorId) async {
    final querySnapshot = await FirebaseService.productsCollection
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .get();

    _vendorProducts = querySnapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  Future<void> _loadVendorOrders(String vendorId) async {
    // Get orders that contain products from this vendor
    final querySnapshot = await FirebaseService.ordersCollection
        .orderBy('createdAt', descending: true)
        .get();

    _vendorOrders = querySnapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .where((order) => order.items.any((item) => 
            _vendorProducts.any((product) => product.id == item.productId)))
        .toList();
  }

  void _calculateAnalytics() {
    _totalProducts = _vendorProducts.length;
    _totalOrders = _vendorOrders.length;
    _totalRevenue = _vendorOrders
        .where((order) => order.status != OrderStatus.cancelled)
        .fold(0, (sum, order) => sum + order.total);

    // Calculate monthly revenue
    _monthlyRevenue.clear();
    for (final order in _vendorOrders) {
      if (order.status != OrderStatus.cancelled) {
        final monthKey = '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}';
        _monthlyRevenue[monthKey] = (_monthlyRevenue[monthKey] ?? 0) + order.total;
      }
    }
  }

  Future<bool> addProduct({
    required String vendorId,
    required String vendorName,
    required String name,
    required String description,
    required double price,
    required List<String> images,
    required String category,
    required int stock,
    List<String> sizes = const [],
    List<String> colors = const [],
    List<String> tags = const [],
    bool isFeatured = false,
    double? discount,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final product = ProductModel(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        price: price,
        images: images,
        category: category,
        vendorId: vendorId,
        vendorName: vendorName,
        stock: stock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sizes: sizes,
        colors: colors,
        tags: tags,
        isFeatured: isFeatured,
        discount: discount,
      );

      final docRef = await FirebaseService.productsCollection.add(product.toFirestore());
      
      _vendorProducts.insert(0, ProductModel(
        id: docRef.id,
        name: name,
        description: description,
        price: price,
        images: images,
        category: category,
        vendorId: vendorId,
        vendorName: vendorName,
        stock: stock,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
        sizes: sizes,
        colors: colors,
        tags: tags,
        isFeatured: isFeatured,
        discount: discount,
      ));

      _totalProducts = _vendorProducts.length;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل إضافة المنتج');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      
      await FirebaseService.productsCollection
          .doc(product.id)
          .update(updatedProduct.toFirestore());

      final index = _vendorProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _vendorProducts[index] = updatedProduct;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('فشل تحديث المنتج');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.productsCollection.doc(productId).delete();
      
      _vendorProducts.removeWhere((product) => product.id == productId);
      _totalProducts = _vendorProducts.length;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('فشل حذف المنتج');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await FirebaseService.ordersCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final orderIndex = _vendorOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _vendorOrders[orderIndex] = _vendorOrders[orderIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        _calculateAnalytics();
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('فشل تحديث حالة الطلب');
      return false;
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