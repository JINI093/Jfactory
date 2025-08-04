enum InquiryStatus { pending, answered, closed }

enum InquiryType { general, technical, payment, complaint, other }

class InquiryEntity {
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

  const InquiryEntity({
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

  InquiryEntity copyWith({
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
    return InquiryEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InquiryEntity &&
        other.id == id &&
        other.userId == userId &&
        other.companyId == companyId &&
        other.title == title &&
        other.content == content &&
        other.type == type &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.answeredAt == answeredAt &&
        other.answer == answer &&
        other.adminId == adminId &&
        _listEquals(other.attachments, attachments);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        companyId.hashCode ^
        title.hashCode ^
        content.hashCode ^
        type.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        answeredAt.hashCode ^
        answer.hashCode ^
        adminId.hashCode ^
        attachments.hashCode;
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