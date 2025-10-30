class CompanyEntity {
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

  const CompanyEntity({
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

  CompanyEntity copyWith({
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
    return CompanyEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CompanyEntity &&
        other.id == id &&
        other.companyName == companyName &&
        other.ceoName == ceoName &&
        other.phone == phone &&
        other.address == address &&
        other.detailAddress == detailAddress &&
        other.category == category &&
        other.subcategory == subcategory &&
        other.subSubcategory == subSubcategory &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.website == website &&
        other.greeting == greeting &&
        _listEquals(other.photos, photos) &&
        other.logo == logo &&
        other.adPayment == adPayment &&
        other.isPremium == isPremium &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt &&
        other.adExpiryDate == adExpiryDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyName.hashCode ^
        ceoName.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        detailAddress.hashCode ^
        category.hashCode ^
        subcategory.hashCode ^
        subSubcategory.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        website.hashCode ^
        greeting.hashCode ^
        photos.hashCode ^
        logo.hashCode ^
        adPayment.hashCode ^
        isPremium.hashCode ^
        isVerified.hashCode ^
        createdAt.hashCode ^
        adExpiryDate.hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}