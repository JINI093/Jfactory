enum PostStatus { draft, published, hidden, deleted }

class PostEntity {
  final String id;
  final String companyId;
  final String title;
  final String content;
  final List<String> images;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int viewCount;
  final List<String> tags;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  
  // Equipment/Post specific fields
  final String? category;
  final String? subcategory;
  final String? subSubcategory;
  final String? equipmentName;
  final String? manufacturer;
  final String? model;
  final String? dimensionX;
  final String? dimensionY;
  final String? dimensionZ;
  final String? weight;
  final String? tableSize;
  final String? features;
  final String? quantity;
  final String? industry;
  final String? machiningCenter;
  final String? basicSpecs;

  const PostEntity({
    required this.id,
    required this.companyId,
    required this.title,
    required this.content,
    required this.images,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.viewCount,
    required this.tags,
    required this.isPremium,
    this.premiumExpiryDate,
    this.category,
    this.subcategory,
    this.subSubcategory,
    this.equipmentName,
    this.manufacturer,
    this.model,
    this.dimensionX,
    this.dimensionY,
    this.dimensionZ,
    this.weight,
    this.tableSize,
    this.features,
    this.quantity,
    this.industry,
    this.machiningCenter,
    this.basicSpecs,
  });

  PostEntity copyWith({
    String? id,
    String? companyId,
    String? title,
    String? content,
    List<String>? images,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    List<String>? tags,
    bool? isPremium,
    DateTime? premiumExpiryDate,
  }) {
    return PostEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostEntity &&
        other.id == id &&
        other.companyId == companyId &&
        other.title == title &&
        other.content == content &&
        _listEquals(other.images, images) &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.viewCount == viewCount &&
        _listEquals(other.tags, tags) &&
        other.isPremium == isPremium &&
        other.premiumExpiryDate == premiumExpiryDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        title.hashCode ^
        content.hashCode ^
        images.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        viewCount.hashCode ^
        tags.hashCode ^
        isPremium.hashCode ^
        premiumExpiryDate.hashCode;
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