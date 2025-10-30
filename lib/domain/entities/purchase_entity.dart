enum PurchaseStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum PurchaseType {
  basicAd,     // 기본 광고
  premiumAd,   // 프리미엄 광고
  featured,    // 추천 광고
}

class PurchaseEntity {
  final String id;
  final String userId;
  final String companyId;
  final PurchaseType purchaseType;
  final double amount;
  final String currency;
  final PurchaseStatus status;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String? productId; // In-app purchase product ID
  final String? transactionId; // Store transaction ID
  final Map<String, dynamic>? metadata;

  PurchaseEntity({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.purchaseType,
    required this.amount,
    required this.currency,
    required this.status,
    required this.purchaseDate,
    this.expiryDate,
    this.productId,
    this.transactionId,
    this.metadata,
  });

  PurchaseEntity copyWith({
    String? id,
    String? userId,
    String? companyId,
    PurchaseType? purchaseType,
    double? amount,
    String? currency,
    PurchaseStatus? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? productId,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) {
    return PurchaseEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      purchaseType: purchaseType ?? this.purchaseType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      productId: productId ?? this.productId,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
    );
  }
}