enum UserType { individual, company }

class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserType userType;
  final DateTime createdAt;
  // Company fields
  final String? companyName;
  final String? businessLicense;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.companyName,
    this.businessLicense,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserType? userType,
    DateTime? createdAt,
    String? companyName,
    String? businessLicense,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
      businessLicense: businessLicense ?? this.businessLicense,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.phone == phone &&
        other.userType == userType &&
        other.createdAt == createdAt &&
        other.companyName == companyName &&
        other.businessLicense == businessLicense;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        userType.hashCode ^
        createdAt.hashCode ^
        companyName.hashCode ^
        businessLicense.hashCode;
  }
}