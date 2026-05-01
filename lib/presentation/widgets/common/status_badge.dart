import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status; // open, partial, paid, cash, credit

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config[status] ?? _config['open']!;

    final Color color = config['color'] as Color;
    final String label = config['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static final Map<String, Map<String, Object>> _config = {
    'open': {
      'label': 'Ouverte',
      'color': AppColors.error,
    },
    'partial': {
      'label': 'Partielle',
      'color': AppColors.warning,
    },
    'paid': {
      'label': 'Payée',
      'color': AppColors.success,
    },
    'cash': {
      'label': 'Espèces',
      'color': AppColors.success,
    },
    'credit': {
      'label': 'Crédit',
      'color': AppColors.accent,
    },
    'offline': {
      'label': 'Hors ligne',
      'color': AppColors.offline,
    },
  };
}