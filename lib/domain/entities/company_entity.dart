class CompanyEntity {
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

  const CompanyEntity({
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

  CompanyEntity copyWith({
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
    return CompanyEntity(
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
        other.website == website &&
        other.greeting == greeting &&
        _listEquals(other.photos, photos) &&
        other.logo == logo &&
        other.adPayment == adPayment &&
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
        website.hashCode ^
        greeting.hashCode ^
        photos.hashCode ^
        logo.hashCode ^
        adPayment.hashCode ^
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