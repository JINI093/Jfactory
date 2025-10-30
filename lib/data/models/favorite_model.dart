import '../../domain/entities/favorite_entity.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String companyId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyId: json['companyId'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FavoriteEntity toEntity() {
    return FavoriteEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      createdAt: createdAt,
    );
  }

  factory FavoriteModel.fromEntity(FavoriteEntity entity) {
    return FavoriteModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      createdAt: entity.createdAt,
    );
  }
}