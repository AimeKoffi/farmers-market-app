import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmers_market_app/presentation/providers/cart_provider.dart';

CartItem _item(int id, {double price = 10.0, int qty = 1}) => CartItem(
      productId: id,
      name: 'Produit $id',
      unitPrice: price,
      quantity: qty,
    );

void main() {
  group('CartItem', () {
    test('subtotal = unitPrice × quantity', () {
      final item = _item(1, price: 5.0, qty: 3);
      expect(item.subtotal, 15.0);
    });

    test('quantity par défaut est 1', () {
      final item = CartItem(productId: 1, name: 'P', unitPrice: 10.0);
      expect(item.quantity, 1);
    });
  });

  group('CartNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('commence vide', () {
      expect(container.read(cartProvider), isEmpty);
    });

    test('addItem ajoute un nouveau produit', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.productId, 1);
    });

    test('addItem incrémente la quantité si le produit existe déjà', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).addItem(_item(1));
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.quantity, 2);
    });

    test('addItem ne touche pas aux autres produits', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).addItem(_item(2));
      expect(container.read(cartProvider).length, 2);
      expect(container.read(cartProvider).first.quantity, 1);
    });

    test('removeItem supprime le bon produit', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).addItem(_item(2));
      container.read(cartProvider.notifier).removeItem(1);
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.productId, 2);
    });

    test('removeItem sur id inexistant ne change rien', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).removeItem(99);
      expect(container.read(cartProvider).length, 1);
    });

    test('updateQuantity change la quantité', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).updateQuantity(1, 5);
      expect(container.read(cartProvider).first.quantity, 5);
    });

    test('updateQuantity à 0 supprime l\'article', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).updateQuantity(1, 0);
      expect(container.read(cartProvider), isEmpty);
    });

    test('updateQuantity négatif supprime l\'article', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).updateQuantity(1, -1);
      expect(container.read(cartProvider), isEmpty);
    });

    test('clear vide le panier', () {
      container.read(cartProvider.notifier).addItem(_item(1));
      container.read(cartProvider.notifier).addItem(_item(2));
      container.read(cartProvider.notifier).clear();
      expect(container.read(cartProvider), isEmpty);
    });

    test('total = somme des subtotaux', () {
      container.read(cartProvider.notifier).addItem(_item(1, price: 10.0, qty: 2));
      container.read(cartProvider.notifier).addItem(_item(2, price: 5.0, qty: 3));
      // 10×2 + 5×3 = 35
      expect(container.read(cartProvider.notifier).total, 35.0);
    });

    test('total est 0 sur panier vide', () {
      expect(container.read(cartProvider.notifier).total, 0.0);
    });
  });
}
