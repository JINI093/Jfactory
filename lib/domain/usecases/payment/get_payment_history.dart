import '../../entities/payment_entity.dart';
import '../../repositories/payment_repository.dart';

class GetPaymentHistoryUseCase {
  final PaymentRepository _paymentRepository;

  GetPaymentHistoryUseCase(this._paymentRepository);

  Future<List<PaymentEntity>> call(String userId) async {
    // 입력 값 유효성 검사
    if (userId.isEmpty) {
      throw Exception('사용자 ID를 입력해주세요.');
    }

    try {
      return await _paymentRepository.getPaymentHistory(userId);
    } catch (e) {
      throw Exception('결제 내역 조회 실패: ${e.toString()}');
    }
  }
}