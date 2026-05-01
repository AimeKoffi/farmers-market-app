import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/farmer_provider.dart';
import '../../widgets/common/status_badge.dart';

class FarmerDetailScreen extends ConsumerWidget {
  final int farmerId;
  const FarmerDetailScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(farmerDebtsProvider(farmerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dettes & historique')),
      body: debtsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (data) {
          final farmer   = data['farmer'] as Map;
          final debts    = data['open_debts'] as List;
          final total    = (data['total_debt'] as num).toDouble();
          final limit    = (farmer['credit_limit'] as num).toDouble();
          final ratio    = limit > 0 ? (total / limit).clamp(0.0, 1.0) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Carte résumé ──────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              child: Text(
                                (farmer['firstname'] as String)[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${farmer['firstname']} ${farmer['lastname']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    farmer['identifier'],
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Barre de crédit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Utilisation du crédit',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(
                              '${total.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio.toDouble(),
                            minHeight: 10,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation(
                              ratio > 0.8
                                  ? AppColors.error
                                  : ratio > 0.5
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatChip(
                              label: 'Dette totale',
                              value: '${total.toStringAsFixed(0)} FCFA',
                              color: AppColors.error,
                            ),
                            _StatChip(
                              label: 'Disponible',
                              value:
                                  '${(limit - total).clamp(0, double.infinity).toStringAsFixed(0)} FCFA',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Boutons d'action ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/farmers/$farmerId/checkout'),
                        icon: const Icon(Icons.shopping_cart, size: 16),
                        label: const Text('Commande'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/farmers/$farmerId/repayment'),
                        icon: const Icon(Icons.grass, size: 16),
                        label: const Text('Rembourser'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Liste des dettes ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dettes ouvertes (${debts.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary),
                    ),
                    const Text(
                      'ordre FIFO →',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (debts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 36),
                        SizedBox(height: 8),
                        Text('Aucune dette en cours',
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  ...debts.asMap().entries.map((entry) {
                    final i    = entry.key;
                    final debt = entry.value as Map;
                    final remaining =
                        (debt['remaining_fcfa'] as num).toDouble();
                    final original =
                        (debt['amount_fcfa'] as num).toDouble();
                    final paid = original - remaining;
                    final ratio = original > 0
                        ? (remaining / original).clamp(0.0, 1.0)
                        : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: i == 0
                                              ? AppColors.error
                                              : AppColors.textSecondary
                                                  .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: i == 0
                                                  ? Colors.white
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Dette #${debt['id']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      if (i == 0) ...[
                                        const SizedBox(width: 6),
                                        const Text('← prochain',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.error)),
                                      ],
                                    ],
                                  ),
                                  StatusBadge(status: debt['status']),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ratio.toDouble(),
                                  minHeight: 7,
                                  backgroundColor: AppColors.divider,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.error),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reste : ${remaining.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Payé : ${paid.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Créé le ${debt['created_at']}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      );
}