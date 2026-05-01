import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/service_providers.dart';
import '../../widgets/common/app_button.dart';

class CreateFarmerScreen extends ConsumerStatefulWidget {
  const CreateFarmerScreen({super.key});
  @override
  ConsumerState<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends ConsumerState<CreateFarmerScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _idCtrl     = TextEditingController();
  final _firstCtrl  = TextEditingController();
  final _lastCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _limitCtrl  = TextEditingController();
  bool _isLoading   = false;

  @override
  void dispose() {
    for (final c in [_idCtrl, _firstCtrl, _lastCtrl, _phoneCtrl, _limitCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(farmerServiceProvider).create({
        'identifier':   _idCtrl.text.trim(),
        'firstname':    _firstCtrl.text.trim(),
        'lastname':     _lastCtrl.text.trim(),
        'phone':        _phoneCtrl.text.trim(),
        'credit_limit': double.parse(_limitCtrl.text),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✓ Agriculteur créé avec succès'),
        backgroundColor: AppColors.success,
      ));
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : ${e.toString()}'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel agriculteur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(_idCtrl,    'Identifiant (carte agricole)',
                  Icons.badge_outlined,   required: true),
              _buildField(_firstCtrl, 'Prénom',
                  Icons.person_outline,   required: true),
              _buildField(_lastCtrl,  'Nom de famille',
                  Icons.person_outline,   required: true),
              _buildField(_phoneCtrl, 'Téléphone',
                  Icons.phone_outlined,
                  keyboard: TextInputType.phone, required: true),
              _buildField(_limitCtrl, 'Limite de crédit (FCFA)',
                  Icons.account_balance_wallet_outlined,
                  keyboard: TextInputType.number,
                  suffix: 'FCFA', required: true),
              const SizedBox(height: 28),
              AppButton(
                label: 'Créer le profil',
                icon: Icons.person_add,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    String? suffix,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixText: suffix,
        ),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Ce champ est requis' : null
            : null,
      ),
    );
  }
}