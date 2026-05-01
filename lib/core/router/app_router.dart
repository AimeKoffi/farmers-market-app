import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/farmer/farmer_search_screen.dart';
import '../../presentation/screens/farmer/farmer_detail_screen.dart';
import '../../presentation/screens/farmer/create_farmer_screen.dart';
import '../../presentation/screens/products/product_list_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/repayment/repayment_screen.dart';
import '../../presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.token != null;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/farmers';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/farmers',
        builder: (_, __) => const FarmerSearchScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, __) => const CreateFarmerScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => FarmerDetailScreen(
              farmerId: int.parse(state.pathParameters['id']!),
            ),
            routes: [
              GoRoute(
                path: 'checkout',
                builder: (_, state) => CheckoutScreen(
                  farmerId: int.parse(state.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'repayment',
                builder: (_, state) => RepaymentScreen(
                  farmerId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/products',
        builder: (_, __) => const ProductListScreen(),
      ),
    ],
  );
});