import '../../domain/entities/post_entity.dart';

class PostModel {
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

  PostModel({
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
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      status: PostStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PostStatus.draft,
      ),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'])
              : (json['updatedAt'] as dynamic).toDate())
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? (json['premiumExpiryDate'] is String
              ? DateTime.parse(json['premiumExpiryDate'])
              : (json['premiumExpiryDate'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'title': title,
      'content': content,
      'images': images,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'viewCount': viewCount,
      'tags': tags,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
    };
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      companyId: companyId,
      title: title,
      content: content,
      images: images,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      viewCount: viewCount,
      tags: tags,
      isPremium: isPremium,
      premiumExpiryDate: premiumExpiryDate,
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      companyId: entity.companyId,
      title: entity.title,
      content: entity.content,
      images: entity.images,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      viewCount: entity.viewCount,
      tags: entity.tags,
      isPremium: entity.isPremium,
      premiumExpiryDate: entity.premiumExpiryDate,
    );
  }

  PostModel copyWith({
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
    return PostModel(
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
}