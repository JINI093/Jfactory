class FavoriteEntity {
  final String id;
  final String userId;
  final String companyId;
  final DateTime createdAt;

  FavoriteEntity({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          companyId == other.companyId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ companyId.hashCode;
}