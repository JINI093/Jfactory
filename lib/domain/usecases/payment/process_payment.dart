import '../../entities/payment_entity.dart';
import '../../repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepository _paymentRepository;

  ProcessPaymentUseCase(this._paymentRepository);

  Future<PaymentEntity> call(ProcessPaymentParams params) async {
    // 입력 값 유효성 검사
    _validateInput(params);

    try {
      return await _paymentRepository.processPayment(
        userId: params.userId,
        companyId: params.companyId,
        amount: params.amount,
        paymentMethod: params.paymentMethod,
        adDurationDays: params.adDurationDays,
      );
    } catch (e) {
      throw Exception('결제 처리 실패: ${e.toString()}');
    }
  }

  void _validateInput(ProcessPaymentParams params) {
    if (params.userId.isEmpty) {
      throw Exception('사용자 ID가 없습니다.');
    }

    if (params.companyId.isEmpty) {
      throw Exception('기업 ID가 없습니다.');
    }

    if (params.amount <= 0) {
      throw Exception('결제 금액은 0보다 커야 합니다.');
    }

    if (params.adDurationDays <= 0) {
      throw Exception('광고 기간은 0보다 커야 합니다.');
    }

    // 최소/최대 결제 금액 검증
    if (params.amount < 1000) {
      throw Exception('최소 결제 금액은 1,000원입니다.');
    }

    if (params.amount > 10000000) {
      throw Exception('최대 결제 금액은 10,000,000원입니다.');
    }

    // 광고 기간 제한
    if (params.adDurationDays > 365) {
      throw Exception('광고 기간은 최대 365일입니다.');
    }
  }
}

class ProcessPaymentParams {
  final String userId;
  final String companyId;
  final double amount;
  final PaymentMethod paymentMethod;
  final int adDurationDays;

  ProcessPaymentParams({
    required this.userId,
    required this.companyId,
    required this.amount,
    required this.paymentMethod,
    required this.adDurationDays,
  });

  // 편의를 위한 팩토리 생성자들
  factory ProcessPaymentParams.basic({
    required String userId,
    required String companyId,
    required PaymentMethod paymentMethod,
  }) {
    return ProcessPaymentParams(
      userId: userId,
      companyId: companyId,
      amount: 30000, // 기본 광고비 3만원
      paymentMethod: paymentMethod,
      adDurationDays: 30, // 30일
    );
  }

  factory ProcessPaymentParams.premium({
    required String userId,
    required String companyId,
    required PaymentMethod paymentMethod,
  }) {
    return ProcessPaymentParams(
      userId: userId,
      companyId: companyId,
      amount: 100000, // 프리미엄 광고비 10만원
      paymentMethod: paymentMethod,
      adDurationDays: 90, // 90일
    );
  }

  factory ProcessPaymentParams.custom({
    required String userId,
    required String companyId,
    required double amount,
    required PaymentMethod paymentMethod,
    required int days,
  }) {
    return ProcessPaymentParams(
      userId: userId,
      companyId: companyId,
      amount: amount,
      paymentMethod: paymentMethod,
      adDurationDays: days,
    );
  }
}