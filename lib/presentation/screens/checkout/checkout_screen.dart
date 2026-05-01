import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/farmer_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/offline_banner.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final int farmerId;
  const CheckoutScreen({super.key, required this.farmerId});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _paymentMethod = 'cash';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    ref.read(productServiceProvider).getProducts(); // preload
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final farmerAsync = ref.watch(farmerDetailProvider(widget.farmerId));
    final total = ref.read(cartProvider.notifier).total;
    const interestRate = 0.30;
    final totalCredit = total * (1 + interestRate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle commande'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.category_outlined), text: 'Produits'),
            Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Panier'),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          farmerAsync.when(
            data: (farmer) => _buildFarmerBar(farmer),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProductsTab(farmerId: widget.farmerId),
                _buildCartTab(cart, total, totalCredit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerBar(Map<String, dynamic> farmer) {
    return Container(
      color: AppColors.primaryLight.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            '${farmer['firstname']} ${farmer['lastname']}',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Text(
            'Dispo: ${(farmer['available_credit'] ?? 0).toStringAsFixed(0)} FCFA',
            style: const TextStyle(color: AppColors.success, fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCartTab(List<CartItem> cart, double total, double totalCredit) {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('Panier vide',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('Ajouter des produits'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = cart[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text('${item.unitPrice.toStringAsFixed(0)} FCFA/u',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      // Contrôle quantité
                      Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.productId, item.quantity - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          _QtyButton(
                            icon: Icons.add,
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.productId, item.quantity + 1),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Text('${item.subtotal.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Récapitulatif + paiement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Column(
            children: [
              // Mode de paiement
              Row(
                children: [
                  Expanded(
                    child: _PaymentTile(
                      label: 'Espèces',
                      icon: Icons.payments_outlined,
                      value: 'cash',
                      selected: _paymentMethod == 'cash',
                      amount: total,
                      onTap: () => setState(() => _paymentMethod = 'cash'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PaymentTile(
                      label: 'Crédit (30%)',
                      icon: Icons.credit_card,
                      value: 'credit',
                      selected: _paymentMethod == 'credit',
                      amount: totalCredit,
                      onTap: () => setState(() => _paymentMethod = 'credit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppButton(
                label: _paymentMethod == 'cash'
                    ? 'Confirmer — ${total.toStringAsFixed(0)} FCFA'
                    : 'Crédit — ${totalCredit.toStringAsFixed(0)} FCFA',
                isLoading: _isSubmitting,
                icon: Icons.check_circle_outline,
                color: _paymentMethod == 'credit'
                    ? AppColors.accent
                    : AppColors.primary,
                onPressed: _submitOrder,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await ref.read(transactionServiceProvider).createTransaction({
        'farmer_id': widget.farmerId,
        'payment_method': _paymentMethod,
        'items': cart.map((e) => {
          'product_id': e.productId,
          'quantity': e.quantity,
          'unit_price': e.unitPrice,
        }).toList(),
      });

      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;

      final isOffline = result['offline'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isOffline
            ? '✓ Sauvegardé hors ligne — sera synchronisé'
            : '✓ Commande enregistrée avec succès'),
        backgroundColor: isOffline ? AppColors.warning : AppColors.success,
      ));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : ${e.toString()}'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: AppColors.primary),
    ),
  );
}

class _PaymentTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool selected;
  final double amount;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.label, required this.value, required this.icon,
    required this.selected, required this.amount, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: selected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12,
                  color: selected ? AppColors.primary : AppColors.textSecondary)),
          Text('${amount.toStringAsFixed(0)} F',
              style: TextStyle(
                  fontSize: 11,
                  color: selected ? AppColors.primary : AppColors.textSecondary)),
        ],
      ),
    ),
  );
}

// Tab produits avec navigation par catégorie
class _ProductsTab extends ConsumerWidget {
  final int farmerId;
  const _ProductsTab({required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsFuture = ref.watch(
      FutureProvider((r) => r.read(productServiceProvider).getProducts()).future,
    );

    return FutureBuilder<List<dynamic>>(
      future: productsFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        final products = snap.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = products[i] as Map;
            return Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(p['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  p['category']?['name'] ?? '',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(p['price_fcfa'] as num).toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(CartItem(
                          productId: p['id'],
                          name: p['name'],
                          unitPrice: (p['price_fcfa'] as num).toDouble(),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${p['name']} ajouté'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.success,
                        ));
                      },
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}