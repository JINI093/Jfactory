import '../../entities/inquiry_entity.dart';
import '../../repositories/inquiry_repository.dart';

class GetInquiriesByUserUseCase {
  final InquiryRepository _inquiryRepository;

  GetInquiriesByUserUseCase(this._inquiryRepository);

  Future<List<InquiryEntity>> call(String userId) async {
    try {
      return await _inquiryRepository.getInquiriesByUser(userId);
    } catch (e) {
      throw Exception('사용자 문의 목록 조회 실패: ${e.toString()}');
    }
  }
}