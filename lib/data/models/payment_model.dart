import '../../domain/entities/payment_entity.dart';

class PaymentModel {
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

  PaymentModel({
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

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyId: json['companyId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
        orElse: () => PaymentMethod.card,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is String
              ? DateTime.parse(json['completedAt'])
              : (json['completedAt'] as dynamic).toDate())
          : null,
      transactionId: json['transactionId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      failureReason: json['failureReason'] as String?,
      adDurationDays: json['adDurationDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'amount': amount,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'receiptUrl': receiptUrl,
      'failureReason': failureReason,
      'adDurationDays': adDurationDays,
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: createdAt,
      completedAt: completedAt,
      transactionId: transactionId,
      receiptUrl: receiptUrl,
      failureReason: failureReason,
      adDurationDays: adDurationDays,
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      transactionId: entity.transactionId,
      receiptUrl: entity.receiptUrl,
      failureReason: entity.failureReason,
      adDurationDays: entity.adDurationDays,
    );
  }

  PaymentModel copyWith({
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
    return PaymentModel(
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
}