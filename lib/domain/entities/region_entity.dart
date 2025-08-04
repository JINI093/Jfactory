class RegionEntity {
  final String id;
  final String name;
  final String? parentId;
  final int level; // 0: 시/도, 1: 구/군, 2: 동/읍/면
  final double? latitude;
  final double? longitude;

  const RegionEntity({
    required this.id,
    required this.name,
    this.parentId,
    required this.level,
    this.latitude,
    this.longitude,
  });

  RegionEntity copyWith({
    String? id,
    String? name,
    String? parentId,
    int? level,
    double? latitude,
    double? longitude,
  }) {
    return RegionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegionEntity &&
        other.id == id &&
        other.name == name &&
        other.parentId == parentId &&
        other.level == level &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        parentId.hashCode ^
        level.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}