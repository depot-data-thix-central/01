import 'package:thix_id/models/thix_money/transaction_model.dart';

class TransactionService {
  /// Get all transactions for the current user
  Future<List<TransactionModel>> getAllTransactions() async {
    // TODO: Implement real transaction fetching from Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// Get recent transactions (limited list)
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    // TODO: Implement real transaction fetching from Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// Get merchant transactions
  Future<List<TransactionModel>> getMerchantTransactions() async {
    // TODO: Implement merchant transaction fetching from Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
}
