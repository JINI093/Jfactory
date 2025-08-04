import 'package:flutter/material.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/payment/process_payment.dart';
import '../../domain/usecases/payment/get_payment_history.dart';

enum PaymentLoadingState {
  initial,
  loading,
  success,
  error,
}

class PaymentViewModel extends ChangeNotifier {
  final ProcessPaymentUseCase _processPaymentUseCase;
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;

  PaymentViewModel({
    required ProcessPaymentUseCase processPaymentUseCase,
    required GetPaymentHistoryUseCase getPaymentHistoryUseCase,
  })  : _processPaymentUseCase = processPaymentUseCase,
        _getPaymentHistoryUseCase = getPaymentHistoryUseCase;

  // State
  PaymentLoadingState _loadingState = PaymentLoadingState.initial;
  List<PaymentEntity> _paymentHistory = [];
  PaymentEntity? _currentPayment;
  String? _errorMessage;

  // Getters
  PaymentLoadingState get loadingState => _loadingState;
  List<PaymentEntity> get paymentHistory => _paymentHistory;
  PaymentEntity? get currentPayment => _currentPayment;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == PaymentLoadingState.loading;

  // Process payment
  Future<bool> processPayment({
    required String userId,
    required String companyId,
    required double amount,
    required PaymentMethod paymentMethod,
    required int adDurationDays,
  }) async {
    _loadingState = PaymentLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final paymentParams = ProcessPaymentParams(
        userId: userId,
        companyId: companyId,
        amount: amount,
        paymentMethod: paymentMethod,
        adDurationDays: adDurationDays,
      );

      final payment = await _processPaymentUseCase(paymentParams);
      _currentPayment = payment;
      _loadingState = PaymentLoadingState.success;
      
      // Add to payment history
      _paymentHistory.insert(0, payment);
      
      notifyListeners();
      return true;
    } catch (e) {
      _loadingState = PaymentLoadingState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load payment history
  Future<void> loadPaymentHistory(String userId) async {
    _loadingState = PaymentLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _paymentHistory = await _getPaymentHistoryUseCase(userId);
      _loadingState = PaymentLoadingState.success;
    } catch (e) {
      _loadingState = PaymentLoadingState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Get payments by status
  List<PaymentEntity> getPaymentsByStatus(PaymentStatus status) {
    return _paymentHistory.where((payment) => payment.status == status).toList();
  }

  // Get completed payments
  List<PaymentEntity> get completedPayments {
    return getPaymentsByStatus(PaymentStatus.completed);
  }

  // Get pending payments
  List<PaymentEntity> get pendingPayments {
    return getPaymentsByStatus(PaymentStatus.pending);
  }

  // Get failed payments
  List<PaymentEntity> get failedPayments {
    return getPaymentsByStatus(PaymentStatus.failed);
  }

  // Calculate total spent
  double get totalSpent {
    return completedPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get recent payments (last 10)
  List<PaymentEntity> get recentPayments {
    final sorted = List<PaymentEntity>.from(_paymentHistory)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _loadingState = PaymentLoadingState.initial;
    _paymentHistory = [];
    _currentPayment = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Simulate different payment methods
  Future<bool> processGooglePayPayment({
    required String userId,
    required String companyId,
    required double amount,
    required int adDurationDays,
  }) async {
    return await processPayment(
      userId: userId,
      companyId: companyId,
      amount: amount,
      paymentMethod: PaymentMethod.google,
      adDurationDays: adDurationDays,
    );
  }

  Future<bool> processApplePayPayment({
    required String userId,
    required String companyId,
    required double amount,
    required int adDurationDays,
  }) async {
    return await processPayment(
      userId: userId,
      companyId: companyId,
      amount: amount,
      paymentMethod: PaymentMethod.apple,
      adDurationDays: adDurationDays,
    );
  }

  Future<bool> processKakaoPayPayment({
    required String userId,
    required String companyId,
    required double amount,
    required int adDurationDays,
  }) async {
    return await processPayment(
      userId: userId,
      companyId: companyId,
      amount: amount,
      paymentMethod: PaymentMethod.kakao,
      adDurationDays: adDurationDays,
    );
  }
}