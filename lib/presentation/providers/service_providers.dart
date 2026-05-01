import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/farmer_service.dart';
import '../../data/services/product_service.dart';
import '../../data/services/transaction_service.dart';
import '../../data/services/repayment_service.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authServiceProvider = Provider(
  (ref) => AuthService(ref.watch(apiClientProvider)),
);
final farmerServiceProvider = Provider(
  (ref) => FarmerService(ref.watch(apiClientProvider)),
);
final productServiceProvider = Provider(
  (ref) => ProductService(ref.watch(apiClientProvider)),
);
final transactionServiceProvider = Provider(
  (ref) => TransactionService(ref.watch(apiClientProvider)),
);
final repaymentServiceProvider = Provider(
  (ref) => RepaymentService(ref.watch(apiClientProvider)),
);