import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<void> createPayment(PaymentEntity payment);
  Future<PaymentEntity?> getPayment(String paymentId);
  Future<List<PaymentEntity>> getPaymentsByUser(String userId);
  Future<List<PaymentEntity>> getPaymentsByCompany(String companyId);
  Future<void> updatePayment(PaymentEntity payment);
  Future<PaymentEntity> processPayment({
    required String userId,
    required String companyId,
    required double amount,
    required PaymentMethod paymentMethod,
    required int adDurationDays,
  });
  Future<void> cancelPayment(String paymentId);
  Future<void> refundPayment(String paymentId);
  Future<List<PaymentEntity>> getPaymentHistory(String userId);
}