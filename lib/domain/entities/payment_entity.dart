enum PaymentStatus { pending, completed, failed, cancelled }

enum PaymentMethod { card, bank, kakao, naver, apple, google }

class PaymentEntity {
  final String id;
  final String userId;
  final String companyId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? receiptUrl;
  final String? failureReason;
  final int adDurationDays;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.receiptUrl,
    this.failureReason,
    required this.adDurationDays,
  });

  PaymentEntity copyWith({
    String? id,
    String? userId,
    String? companyId,
    double? amount,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionId,
    String? receiptUrl,
    String? failureReason,
    int? adDurationDays,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      failureReason: failureReason ?? this.failureReason,
      adDurationDays: adDurationDays ?? this.adDurationDays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentEntity &&
        other.id == id &&
        other.userId == userId &&
        other.companyId == companyId &&
        other.amount == amount &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.transactionId == transactionId &&
        other.receiptUrl == receiptUrl &&
        other.failureReason == failureReason &&
        other.adDurationDays == adDurationDays;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        companyId.hashCode ^
        amount.hashCode ^
        paymentMethod.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        completedAt.hashCode ^
        transactionId.hashCode ^
        receiptUrl.hashCode ^
        failureReason.hashCode ^
        adDurationDays.hashCode;
  }
}