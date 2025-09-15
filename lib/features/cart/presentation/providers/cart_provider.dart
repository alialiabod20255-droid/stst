import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/cart_model.dart';
import '../../../../core/services/firebase_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.15; // 15% VAT
  double get shipping => subtotal > 200 ? 0 : 25; // Free shipping over 200 SAR
  double get total => subtotal + tax + shipping;

  Future<void> loadCart(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.cartCollection
          .doc(userId)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .get();

      _items = querySnapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل السلة');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required int quantity,
    String? selectedSize,
    String? selectedColor,
    String? giftWrap,
    String? greetingCard,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if item already exists with same options
      final existingItemIndex = _items.indexWhere((item) =>
          item.productId == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor &&
          item.giftWrap == giftWrap &&
          item.greetingCard == greetingCard);

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = _items[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;
        
        await FirebaseService.cartCollection
            .doc(userId)
            .collection('items')
            .doc(existingItem.id)
            .update({'quantity': newQuantity});

        _items[existingItemIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        // Add new item
        final cartItem = CartItemModel(
          id: '', // Will be set by Firestore
          productId: productId,
          productName: productName,
          productImage: productImage,
          price: price,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          giftWrap: giftWrap,
          greetingCard: greetingCard,
          addedAt: DateTime.now(),
        );

        final docRef = await FirebaseService.cartCollection
            .doc(userId)
            .collection('items')
            .add(cartItem.toFirestore());

        _items.insert(0, CartItemModel(
          id: docRef.id,
          productId: productId,
          productName: productName,
          productImage: productImage,
          price: price,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          giftWrap: giftWrap,
          greetingCard: greetingCard,
          addedAt: DateTime.now(),
        ));
      }

      notifyListeners();
    } catch (e) {
      _setError('فشل إضافة المنتج للسلة');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateQuantity(String userId, String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(userId, itemId);
        return;
      }

      await FirebaseService.cartCollection
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .update({'quantity': newQuantity});

      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        _items[itemIndex] = _items[itemIndex].copyWith(quantity: newQuantity);
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل تحديث الكمية');
    }
  }

  Future<void> removeFromCart(String userId, String itemId) async {
    try {
      await FirebaseService.cartCollection
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .delete();

      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _setError('فشل حذف المنتج من السلة');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final batch = FirebaseFirestore.instance.batch();
      for (final item in _items) {
        batch.delete(FirebaseService.cartCollection
            .doc(userId)
            .collection('items')
            .doc(item.id));
      }
      await batch.commit();

      _items.clear();
      notifyListeners();
    } catch (e) {
      _setError('فشل مسح السلة');
    } finally {
      _setLoading(false);
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