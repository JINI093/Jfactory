import '../../entities/company_entity.dart';
import '../../repositories/company_repository.dart';

class GetCompanyByIdUseCase {
  final CompanyRepository _companyRepository;

  GetCompanyByIdUseCase(this._companyRepository);

  Future<CompanyEntity?> call(String companyId) async {
    // 입력 값 유효성 검사
    if (companyId.isEmpty) {
      throw Exception('기업 ID를 입력해주세요.');
    }

    try {
      return await _companyRepository.getCompany(companyId);
    } catch (e) {
      throw Exception('기업 정보 조회 실패: ${e.toString()}');
    }
  }
}