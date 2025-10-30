import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/purchase_entity.dart';

class PurchaseModel {
  final String id;
  final String userId;
  final String companyId;
  final String purchaseType;
  final double amount;
  final String currency;
  final String status;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String? productId;
  final String? transactionId;
  final Map<String, dynamic>? metadata;

  PurchaseModel({
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

  factory PurchaseModel.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      // purchaseDate는 필수 필드이므로 안전하게 처리
      DateTime purchaseDate = DateTime.now();
      if (data['purchaseDate'] != null) {
        if (data['purchaseDate'] is Timestamp) {
          purchaseDate = (data['purchaseDate'] as Timestamp).toDate();
        } else if (data['purchaseDate'] is String) {
          purchaseDate = DateTime.parse(data['purchaseDate']);
        }
      }
      
      // expiryDate 안전 처리
      DateTime? expiryDate;
      if (data['expiryDate'] != null) {
        if (data['expiryDate'] is Timestamp) {
          expiryDate = (data['expiryDate'] as Timestamp).toDate();
        } else if (data['expiryDate'] is String) {
          expiryDate = DateTime.parse(data['expiryDate']);
        }
      }
      
      return PurchaseModel(
        id: id,
        userId: data['userId']?.toString() ?? '',
        companyId: data['companyId']?.toString() ?? '',
        purchaseType: data['purchaseType']?.toString() ?? 'basicAd',
        amount: _parseDouble(data['amount']) ?? 0.0,
        currency: data['currency']?.toString() ?? 'KRW',
        status: data['status']?.toString() ?? 'pending',
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        productId: data['productId']?.toString(),
        transactionId: data['transactionId']?.toString(),
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw Exception('Failed to parse purchase data for ID $id: $e');
    }
  }
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'companyId': companyId,
      'purchaseType': purchaseType,
      'amount': amount,
      'currency': currency,
      'status': status,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'productId': productId,
      'transactionId': transactionId,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  PurchaseEntity toEntity() {
    return PurchaseEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      purchaseType: _stringToPurchaseType(purchaseType),
      amount: amount,
      currency: currency,
      status: _stringToPurchaseStatus(status),
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      productId: productId,
      transactionId: transactionId,
      metadata: metadata,
    );
  }

  static PurchaseModel fromEntity(PurchaseEntity entity) {
    return PurchaseModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      purchaseType: _purchaseTypeToString(entity.purchaseType),
      amount: entity.amount,
      currency: entity.currency,
      status: _purchaseStatusToString(entity.status),
      purchaseDate: entity.purchaseDate,
      expiryDate: entity.expiryDate,
      productId: entity.productId,
      transactionId: entity.transactionId,
      metadata: entity.metadata,
    );
  }

  static PurchaseType _stringToPurchaseType(String type) {
    switch (type) {
      case 'basicAd':
        return PurchaseType.basicAd;
      case 'premiumAd':
        return PurchaseType.premiumAd;
      case 'featured':
        return PurchaseType.featured;
      default:
        return PurchaseType.basicAd;
    }
  }

  static String _purchaseTypeToString(PurchaseType type) {
    switch (type) {
      case PurchaseType.basicAd:
        return 'basicAd';
      case PurchaseType.premiumAd:
        return 'premiumAd';
      case PurchaseType.featured:
        return 'featured';
    }
  }

  static PurchaseStatus _stringToPurchaseStatus(String status) {
    switch (status) {
      case 'pending':
        return PurchaseStatus.pending;
      case 'completed':
        return PurchaseStatus.completed;
      case 'failed':
        return PurchaseStatus.failed;
      case 'refunded':
        return PurchaseStatus.refunded;
      default:
        return PurchaseStatus.pending;
    }
  }

  static String _purchaseStatusToString(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return 'pending';
      case PurchaseStatus.completed:
        return 'completed';
      case PurchaseStatus.failed:
        return 'failed';
      case PurchaseStatus.refunded:
        return 'refunded';
    }
  }
}