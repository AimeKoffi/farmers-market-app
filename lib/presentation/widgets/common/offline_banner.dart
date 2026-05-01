import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.hasData &&
            snapshot.data!.contains(ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: AppColors.offline,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text(
                'Mode hors ligne — les transactions seront synchronisées',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}