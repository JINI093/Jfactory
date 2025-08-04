import '../../domain/entities/inquiry_entity.dart';

class InquiryModel {
  final String id;
  final String userId;
  final String? companyId;
  final String title;
  final String content;
  final InquiryType type;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final String? answer;
  final String? adminId;
  final List<String> attachments;

  InquiryModel({
    required this.id,
    required this.userId,
    this.companyId,
    required this.title,
    required this.content,
    required this.type,
    required this.status,
    required this.createdAt,
    this.answeredAt,
    this.answer,
    this.adminId,
    required this.attachments,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyId: json['companyId'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      type: InquiryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => InquiryType.general,
      ),
      status: InquiryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => InquiryStatus.pending,
      ),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
      answeredAt: json['answeredAt'] != null
          ? (json['answeredAt'] is String
              ? DateTime.parse(json['answeredAt'])
              : (json['answeredAt'] as dynamic).toDate())
          : null,
      answer: json['answer'] as String?,
      adminId: json['adminId'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
      'answer': answer,
      'adminId': adminId,
      'attachments': attachments,
    };
  }

  InquiryEntity toEntity() {
    return InquiryEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      title: title,
      content: content,
      type: type,
      status: status,
      createdAt: createdAt,
      answeredAt: answeredAt,
      answer: answer,
      adminId: adminId,
      attachments: attachments,
    );
  }

  factory InquiryModel.fromEntity(InquiryEntity entity) {
    return InquiryModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      title: entity.title,
      content: entity.content,
      type: entity.type,
      status: entity.status,
      createdAt: entity.createdAt,
      answeredAt: entity.answeredAt,
      answer: entity.answer,
      adminId: entity.adminId,
      attachments: entity.attachments,
    );
  }

  InquiryModel copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? title,
    String? content,
    InquiryType? type,
    InquiryStatus? status,
    DateTime? createdAt,
    DateTime? answeredAt,
    String? answer,
    String? adminId,
    List<String>? attachments,
  }) {
    return InquiryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      answer: answer ?? this.answer,
      adminId: adminId ?? this.adminId,
      attachments: attachments ?? this.attachments,
    );
  }
}