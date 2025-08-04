import '../../entities/inquiry_entity.dart';
import '../../repositories/inquiry_repository.dart';

class CreateInquiryUseCase {
  final InquiryRepository _inquiryRepository;

  CreateInquiryUseCase(this._inquiryRepository);

  Future<void> call(CreateInquiryParams params) async {
    try {
      final inquiry = InquiryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: params.userId,
        companyId: params.companyId,
        title: params.title,
        content: params.content,
        type: params.type,
        status: InquiryStatus.pending,
        createdAt: DateTime.now(),
        attachments: params.attachments,
      );

      await _inquiryRepository.createInquiry(inquiry);
    } catch (e) {
      throw Exception('문의 생성 실패: ${e.toString()}');
    }
  }
}

class CreateInquiryParams {
  final String userId;
  final String? companyId;
  final String title;
  final String content;
  final InquiryType type;
  final List<String> attachments;

  CreateInquiryParams({
    required this.userId,
    this.companyId,
    required this.title,
    required this.content,
    required this.type,
    this.attachments = const [],
  });
}