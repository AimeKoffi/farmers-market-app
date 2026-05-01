import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final int productId;
  final String name;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get subtotal => unitPrice * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final idx = state.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      final updated = [...state];
      updated[idx].quantity++;
      state = updated;
    } else {
      state = [...state, item];
    }
  }

  void removeItem(int productId) {
    state = state.where((e) => e.productId != productId).toList();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.map((e) {
      if (e.productId == productId) e.quantity = quantity;
      return e;
    }).toList();
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, e) => sum + e.subtotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);