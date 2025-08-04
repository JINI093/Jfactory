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
  final String? website;
  final String? greeting;
  final List<String> photos;
  final String? logo;
  final double adPayment;
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
    this.website,
    this.greeting,
    required this.photos,
    this.logo,
    required this.adPayment,
    required this.createdAt,
    this.adExpiryDate,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      ceoName: json['ceoName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      detailAddress: json['detailAddress'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      website: json['website'] as String?,
      greeting: json['greeting'] as String?,
      photos: List<String>.from(json['photos'] ?? []),
      logo: json['logo'] as String?,
      adPayment: (json['adPayment'] as num).toDouble(),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
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
      'website': website,
      'greeting': greeting,
      'photos': photos,
      'logo': logo,
      'adPayment': adPayment,
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
      website: website,
      greeting: greeting,
      photos: photos,
      logo: logo,
      adPayment: adPayment,
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
      website: entity.website,
      greeting: entity.greeting,
      photos: entity.photos,
      logo: entity.logo,
      adPayment: entity.adPayment,
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
    String? website,
    String? greeting,
    List<String>? photos,
    String? logo,
    double? adPayment,
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
      website: website ?? this.website,
      greeting: greeting ?? this.greeting,
      photos: photos ?? this.photos,
      logo: logo ?? this.logo,
      adPayment: adPayment ?? this.adPayment,
      createdAt: createdAt ?? this.createdAt,
      adExpiryDate: adExpiryDate ?? this.adExpiryDate,
    );
  }
}