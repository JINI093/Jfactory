import '../../entities/inquiry_entity.dart';
import '../../repositories/inquiry_repository.dart';

class GetInquiryByIdUseCase {
  final InquiryRepository _inquiryRepository;

  GetInquiryByIdUseCase(this._inquiryRepository);

  Future<InquiryEntity?> call(String inquiryId) async {
    try {
      return await _inquiryRepository.getInquiry(inquiryId);
    } catch (e) {
      throw Exception('문의 조회 실패: ${e.toString()}');
    }
  }
}