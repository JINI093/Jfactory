import '../../domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserType userType;
  final DateTime createdAt;
  final String? companyName;
  final String? businessLicense;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.companyName,
    this.businessLicense,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['userType'],
        orElse: () => UserType.individual,
      ),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
      companyName: json['companyName'] as String?,
      businessLicense: json['businessLicense'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'companyName': companyName,
      'businessLicense': businessLicense,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      userType: userType,
      createdAt: createdAt,
      companyName: companyName,
      businessLicense: businessLicense,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      userType: entity.userType,
      createdAt: entity.createdAt,
      companyName: entity.companyName,
      businessLicense: entity.businessLicense,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserType? userType,
    DateTime? createdAt,
    String? companyName,
    String? businessLicense,
  }) {
    return UserModel(
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
}