import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/offline_banner.dart';
import '../../providers/service_providers.dart';

class FarmerSearchScreen extends ConsumerStatefulWidget {
  const FarmerSearchScreen({super.key});
  @override
  ConsumerState<FarmerSearchScreen> createState() => _FarmerSearchScreenState();
}

class _FarmerSearchScreenState extends ConsumerState<FarmerSearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmerState = ref.watch(farmerSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche Agriculteur'),
        actions: [
          IconButton(
            tooltip: 'Catalogue produits',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.push('/products'),
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).logout();
              } catch (_) {}
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),

          // Barre de recherche
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Identifiant ou téléphone...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _doSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(52, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Résultat
          Expanded(
            child: farmerState.when(
              data: (farmer) {
                if (farmer == null) return _buildEmptyState();
                return _buildFarmerCard(farmer);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => _buildErrorState(e.toString()),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmers/new'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.person_add),
        label: const Text('Nouvel agriculteur',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _doSearch() {
    final q = _searchCtrl.text.trim();
    if (q.length >= 2) {
      ref.read(farmerSearchProvider.notifier).search(q);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('Recherchez un agriculteur',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Par identifiant de carte ou numéro de téléphone',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFarmerCard(Map<String, dynamic> farmer) {
    final debt = (farmer['total_debt'] ?? 0.0) as num;
    final limit = (farmer['credit_limit'] ?? 0.0) as num;
    final available = (farmer['available_credit'] ?? 0.0) as num;
    final ratio = limit > 0 ? (debt / limit).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identité
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          farmer['firstname'][0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${farmer['firstname']} ${farmer['lastname']}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            Text(farmer['identifier'],
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(farmer['phone'],
                            style: const TextStyle(
                                color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Dette / Limite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Limite de crédit',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      Text('${limit.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ratio.toDouble(),
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        ratio > 0.8 ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dette : ${debt.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                              color: debt > 0 ? AppColors.error : AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text('Disponible : ${available.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/farmers/${farmer['id']}/checkout'),
                  icon: const Icon(Icons.shopping_cart, size: 18),
                  label: const Text('Nouvelle commande'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/farmers/${farmer['id']}/repayment'),
                  icon: const Icon(Icons.grass, size: 18),
                  label: const Text('Rembourser'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/farmers/${farmer['id']}'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Voir les dettes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('Agriculteur non trouvé',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Text('Vérifiez l\'identifiant ou le téléphone',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}