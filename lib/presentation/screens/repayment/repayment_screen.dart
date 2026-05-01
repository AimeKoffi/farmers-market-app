import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/service_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

class RepaymentScreen extends ConsumerStatefulWidget {
  final int farmerId;
  const RepaymentScreen({super.key, required this.farmerId});
  @override
  ConsumerState<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends ConsumerState<RepaymentScreen> {
  final _kgCtrl = TextEditingController();
  bool _isSubmitting = false;
  static const double _commodityRate = 1000.0; // depuis settings

  double get _fcfaValue {
    final kg = double.tryParse(_kgCtrl.text) ?? 0;
    return kg * _commodityRate;
  }

  @override
  void dispose() {
    _kgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(farmerDebtsProvider(widget.farmerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Remboursement cacao')),
      body: debtsAsync.when(
        data: (data) => _buildBody(data),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    final farmer = data['farmer'] as Map;
    final debts = data['open_debts'] as List;
    final totalDebt = (data['total_debt'] as num).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé agriculteur
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${farmer['firstname']} ${farmer['lastname']}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(farmer['identifier'],
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Dette totale',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      Text(
                        '${totalDebt.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dettes ouvertes (FIFO)
          const Text('Dettes à rembourser (ordre FIFO)',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...debts.map((d) {
            final debt = d as Map;
            final remaining = (debt['remaining_fcfa'] as num).toDouble();
            final total = (debt['amount_fcfa'] as num).toDouble();
            final ratio = total > 0 ? (remaining / total) : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dette #${debt['id']}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        StatusBadge(status: debt['status']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio.toDouble(),
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reste : ${remaining.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text('Total : ${total.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Saisie kg
          const Text('Enregistrer un remboursement',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _kgCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantité de cacao (kg)',
                      prefixIcon: Icon(Icons.grass, color: AppColors.primary),
                      suffixText: 'kg',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  // Conversion preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_kgCtrl.text.isEmpty ? "0" : _kgCtrl.text} kg'
                            ' × $_commodityRate FCFA/kg'
                            ' = ${_fcfaValue.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Confirmer le remboursement',
                    icon: Icons.check_circle_outline,
                    isLoading: _isSubmitting,
                    onPressed: _fcfaValue > 0 ? _submitRepayment : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRepayment() async {
    final kg = double.tryParse(_kgCtrl.text);
    if (kg == null || kg <= 0) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(repaymentServiceProvider).recordRepayment(
        farmerId: widget.farmerId,
        kgReceived: kg,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✓ Remboursement enregistré'),
        backgroundColor: AppColors.success,
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