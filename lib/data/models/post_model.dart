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
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      subSubcategory: json['subSubcategory'] as String?,
      equipmentName: json['equipmentName'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      dimensionX: json['dimensionX'] as String?,
      dimensionY: json['dimensionY'] as String?,
      dimensionZ: json['dimensionZ'] as String?,
      weight: json['weight'] as String?,
      tableSize: json['tableSize'] as String?,
      features: json['features'] as String?,
      quantity: json['quantity'] as String?,
      industry: json['industry'] as String?,
      machiningCenter: json['machiningCenter'] as String?,
      basicSpecs: json['basicSpecs'] as String?,
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
      'category': category,
      'subcategory': subcategory,
      'subSubcategory': subSubcategory,
      'equipmentName': equipmentName,
      'manufacturer': manufacturer,
      'model': model,
      'dimensionX': dimensionX,
      'dimensionY': dimensionY,
      'dimensionZ': dimensionZ,
      'weight': weight,
      'tableSize': tableSize,
      'features': features,
      'quantity': quantity,
      'industry': industry,
      'machiningCenter': machiningCenter,
      'basicSpecs': basicSpecs,
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
      category: category,
      subcategory: subcategory,
      subSubcategory: subSubcategory,
      equipmentName: equipmentName,
      manufacturer: manufacturer,
      model: model,
      dimensionX: dimensionX,
      dimensionY: dimensionY,
      dimensionZ: dimensionZ,
      weight: weight,
      tableSize: tableSize,
      features: features,
      quantity: quantity,
      industry: industry,
      machiningCenter: machiningCenter,
      basicSpecs: basicSpecs,
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
      category: entity.category,
      subcategory: entity.subcategory,
      subSubcategory: entity.subSubcategory,
      equipmentName: entity.equipmentName,
      manufacturer: entity.manufacturer,
      model: entity.model,
      dimensionX: entity.dimensionX,
      dimensionY: entity.dimensionY,
      dimensionZ: entity.dimensionZ,
      weight: entity.weight,
      tableSize: entity.tableSize,
      features: entity.features,
      quantity: entity.quantity,
      industry: entity.industry,
      machiningCenter: entity.machiningCenter,
      basicSpecs: entity.basicSpecs,
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
    String? category,
    String? subcategory,
    String? subSubcategory,
    String? equipmentName,
    String? manufacturer,
    String? model,
    String? dimensionX,
    String? dimensionY,
    String? dimensionZ,
    String? weight,
    String? tableSize,
    String? features,
    String? quantity,
    String? industry,
    String? machiningCenter,
    String? basicSpecs,
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
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      subSubcategory: subSubcategory ?? this.subSubcategory,
      equipmentName: equipmentName ?? this.equipmentName,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      dimensionX: dimensionX ?? this.dimensionX,
      dimensionY: dimensionY ?? this.dimensionY,
      dimensionZ: dimensionZ ?? this.dimensionZ,
      weight: weight ?? this.weight,
      tableSize: tableSize ?? this.tableSize,
      features: features ?? this.features,
      quantity: quantity ?? this.quantity,
      industry: industry ?? this.industry,
      machiningCenter: machiningCenter ?? this.machiningCenter,
      basicSpecs: basicSpecs ?? this.basicSpecs,
    );
  }
}