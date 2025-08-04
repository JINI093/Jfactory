import '../../entities/company_entity.dart';
import '../../repositories/company_repository.dart';

class UpdateCompanyUseCase {
  final CompanyRepository _companyRepository;

  UpdateCompanyUseCase(this._companyRepository);

  Future<void> call(CompanyEntity company) async {
    // 입력 값 유효성 검사
    _validateInput(company);

    try {
      await _companyRepository.updateCompany(company);
    } catch (e) {
      throw Exception('기업 정보 수정 실패: ${e.toString()}');
    }
  }

  void _validateInput(CompanyEntity company) {
    if (company.id.isEmpty) {
      throw Exception('기업 ID가 없습니다.');
    }

    if (company.companyName.isEmpty) {
      throw Exception('기업명을 입력해주세요.');
    }

    if (company.ceoName.isEmpty) {
      throw Exception('대표자명을 입력해주세요.');
    }

    if (company.phone.isEmpty) {
      throw Exception('전화번호를 입력해주세요.');
    }

    if (company.address.isEmpty) {
      throw Exception('주소를 입력해주세요.');
    }

    if (company.category.isEmpty) {
      throw Exception('카테고리를 선택해주세요.');
    }

    if (company.subcategory.isEmpty) {
      throw Exception('세부 카테고리를 선택해주세요.');
    }

    // 전화번호 형식 검증
    if (!_isValidPhoneNumber(company.phone)) {
      throw Exception('올바른 전화번호 형식이 아닙니다.');
    }

    // 웹사이트 형식 검증 (입력된 경우)
    if (company.website != null && company.website!.isNotEmpty) {
      if (!_isValidWebsite(company.website!)) {
        throw Exception('올바른 웹사이트 주소 형식이 아닙니다.');
      }
    }

    // 광고비 검증
    if (company.adPayment < 0) {
      throw Exception('광고비는 0 이상이어야 합니다.');
    }
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^(010|011|016|017|018|019)-?\d{3,4}-?\d{4}$|^02-?\d{3,4}-?\d{4}$|^0\d{1,2}-?\d{3,4}-?\d{4}$').hasMatch(phone);
  }

  bool _isValidWebsite(String website) {
    return RegExp(r'^https?://.+\..+').hasMatch(website) || 
           RegExp(r'^www\..+\..+').hasMatch(website) ||
           RegExp(r'^.+\..+').hasMatch(website);
  }
}