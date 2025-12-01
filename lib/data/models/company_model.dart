import '../../domain/entities/company_entity.dart';

class CompanyModel {
  final String id;
  final String companyName;
  final String ceoName;
  final String phone;
  final String address;
  final String detailAddress;
  final String category;
  final String subcategory;
  final String? subSubcategory;
  final double? latitude;
  final double? longitude;
  final String? website;
  final String? greeting;
  final List<String> photos;
  final String? logo;
  final double adPayment;
  final bool isPremium;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? adExpiryDate;

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.ceoName,
    required this.phone,
    required this.address,
    required this.detailAddress,
    required this.category,
    required this.subcategory,
    this.subSubcategory,
    this.latitude,
    this.longitude,
    this.website,
    this.greeting,
    required this.photos,
    this.logo,
    required this.adPayment,
    this.isPremium = false,
    required this.isVerified,
    required this.createdAt,
    this.adExpiryDate,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final docId = json['id'] as String?;
    final ownerId = json['userId'] as String?;
    final resolvedId = docId ?? ownerId;

    if (resolvedId == null || resolvedId.isEmpty) {
      throw ArgumentError('CompanyModel.fromJson: company id is missing');
    }

    return CompanyModel(
      id: resolvedId,
      companyName: json['companyName'] as String,
      ceoName: json['ceoName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      detailAddress: json['detailAddress'] as String? ?? '',
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      subSubcategory: json['subSubcategory'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      website: json['website'] as String?,
      greeting: json['greeting'] as String?,
      photos: json['photos'] != null 
          ? List<String>.from(json['photos'])
          : (json['photo'] != null ? [json['photo'] as String] : []), // Handle both photos array and single photo field
      logo: json['logo'] as String?,
      adPayment: (json['adPayment'] as num?)?.toDouble() ?? 0.0, // Default to 0
      isPremium: (json['isPremium'] as bool?) ?? _deriveIsPremium(json),
      isVerified: json['isVerified'] as bool? ?? true, // Default to true
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : (json['createdAt'] as dynamic).toDate())
          : DateTime.now(), // Default to now if missing
      adExpiryDate: json['adExpiryDate'] != null
          ? (json['adExpiryDate'] is String
              ? DateTime.parse(json['adExpiryDate'])
              : (json['adExpiryDate'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'ceoName': ceoName,
      'phone': phone,
      'address': address,
      'detailAddress': detailAddress,
      'category': category,
      'subcategory': subcategory,
      'subSubcategory': subSubcategory,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'greeting': greeting,
      'photos': photos,
      'logo': logo,
      'adPayment': adPayment,
      'isPremium': isPremium,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'adExpiryDate': adExpiryDate?.toIso8601String(),
    };
  }

  CompanyEntity toEntity() {
    return CompanyEntity(
      id: id,
      companyName: companyName,
      ceoName: ceoName,
      phone: phone,
      address: address,
      detailAddress: detailAddress,
      category: category,
      subcategory: subcategory,
      subSubcategory: subSubcategory,
      latitude: latitude,
      longitude: longitude,
      website: website,
      greeting: greeting,
      photos: photos,
      logo: logo,
      adPayment: adPayment,
      isPremium: isPremium,
      isVerified: isVerified,
      createdAt: createdAt,
      adExpiryDate: adExpiryDate,
    );
  }

  factory CompanyModel.fromEntity(CompanyEntity entity) {
    return CompanyModel(
      id: entity.id,
      companyName: entity.companyName,
      ceoName: entity.ceoName,
      phone: entity.phone,
      address: entity.address,
      detailAddress: entity.detailAddress,
      category: entity.category,
      subcategory: entity.subcategory,
      subSubcategory: entity.subSubcategory,
      latitude: entity.latitude,
      longitude: entity.longitude,
      website: entity.website,
      greeting: entity.greeting,
      photos: entity.photos,
      logo: entity.logo,
      adPayment: entity.adPayment,
      isPremium: entity.isPremium,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt,
      adExpiryDate: entity.adExpiryDate,
    );
  }

  CompanyModel copyWith({
    String? id,
    String? companyName,
    String? ceoName,
    String? phone,
    String? address,
    String? detailAddress,
    String? category,
    String? subcategory,
    String? subSubcategory,
    double? latitude,
    double? longitude,
    String? website,
    String? greeting,
    List<String>? photos,
    String? logo,
    double? adPayment,
    bool? isPremium,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? adExpiryDate,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      ceoName: ceoName ?? this.ceoName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      subSubcategory: subSubcategory ?? this.subSubcategory,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      website: website ?? this.website,
      greeting: greeting ?? this.greeting,
      photos: photos ?? this.photos,
      logo: logo ?? this.logo,
      adPayment: adPayment ?? this.adPayment,
      isPremium: isPremium ?? this.isPremium,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      adExpiryDate: adExpiryDate ?? this.adExpiryDate,
    );
  }

  static bool _deriveIsPremium(Map<String, dynamic> json) {
    try {
      final adPayment = (json['adPayment'] as num?)?.toDouble() ?? 0.0;
      DateTime? expiry;
      if (json['adExpiryDate'] != null) {
        expiry = json['adExpiryDate'] is String
            ? DateTime.parse(json['adExpiryDate'])
            : (json['adExpiryDate'] as dynamic).toDate();
      }
      final now = DateTime.now();
      return adPayment > 0 || (expiry != null && expiry.isAfter(now));
    } catch (_) {
      return false;
    }
  }
}