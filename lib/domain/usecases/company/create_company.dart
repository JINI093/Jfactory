import '../../entities/company_entity.dart';
import '../../repositories/company_repository.dart';

class CreateCompanyUseCase {
  final CompanyRepository _companyRepository;

  CreateCompanyUseCase(this._companyRepository);

  Future<void> call(CreateCompanyParams params) async {
    // 입력 값 유효성 검사
    _validateInput(params);

    try {
      final company = CompanyEntity(
        id: params.id,
        companyName: params.companyName,
        ceoName: params.ceoName,
        phone: params.phone,
        address: params.address,
        detailAddress: params.detailAddress,
        category: params.category,
        subcategory: params.subcategory,
        website: params.website,
        greeting: params.greeting,
        photos: params.photos,
        logo: params.logo,
        adPayment: params.adPayment,
        isVerified: true, // 새로 등록되는 기업은 자동으로 승인
        createdAt: DateTime.now(),
        adExpiryDate: params.adExpiryDate,
      );

      await _companyRepository.createCompany(company);
    } catch (e) {
      throw Exception('기업 등록 실패: ${e.toString()}');
    }
  }

  void _validateInput(CreateCompanyParams params) {
    if (params.id.isEmpty) {
      throw Exception('기업 ID를 입력해주세요.');
    }

    if (params.companyName.isEmpty) {
      throw Exception('기업명을 입력해주세요.');
    }

    if (params.ceoName.isEmpty) {
      throw Exception('대표자명을 입력해주세요.');
    }

    if (params.phone.isEmpty) {
      throw Exception('전화번호를 입력해주세요.');
    }

    if (params.address.isEmpty) {
      throw Exception('주소를 입력해주세요.');
    }

    if (params.detailAddress.isEmpty) {
      throw Exception('상세주소를 입력해주세요.');
    }

    if (params.category.isEmpty) {
      throw Exception('카테고리를 선택해주세요.');
    }

    if (params.subcategory.isEmpty) {
      throw Exception('세부 카테고리를 선택해주세요.');
    }

    // 전화번호 형식 검증
    if (!_isValidPhoneNumber(params.phone)) {
      throw Exception('올바른 전화번호 형식이 아닙니다.');
    }

    // 기업명 길이 검증
    if (params.companyName.length < 2) {
      throw Exception('기업명은 2자 이상이어야 합니다.');
    }

    // 대표자명 길이 검증
    if (params.ceoName.length < 2) {
      throw Exception('대표자명은 2자 이상이어야 합니다.');
    }

    // 웹사이트 형식 검증 (입력된 경우)
    if (params.website != null && params.website!.isNotEmpty) {
      if (!_isValidWebsite(params.website!)) {
        throw Exception('올바른 웹사이트 주소 형식이 아닙니다.');
      }
    }

    // 광고비 검증
    if (params.adPayment < 0) {
      throw Exception('광고비는 0 이상이어야 합니다.');
    }

    // 사진 개수 제한
    if (params.photos.length > 10) {
      throw Exception('사진은 최대 10장까지 등록할 수 있습니다.');
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // 한국 전화번호 형식 검증 (일반 전화번호 포함)
    return RegExp(r'^(010|011|016|017|018|019)-?\d{3,4}-?\d{4}$|^02-?\d{3,4}-?\d{4}$|^0\d{1,2}-?\d{3,4}-?\d{4}$').hasMatch(phone);
  }

  bool _isValidWebsite(String website) {
    return RegExp(r'^https?://.+\..+').hasMatch(website) || 
           RegExp(r'^www\..+\..+').hasMatch(website) ||
           RegExp(r'^.+\..+').hasMatch(website);
  }
}

class CreateCompanyParams {
  final String id;
  final String companyName;
  final String ceoName;
  final String phone;
  final String address;
  final String detailAddress;
  final String category;
  final String subcategory;
  final String? website;
  final String? greeting;
  final List<String> photos;
  final String? logo;
  final double adPayment;
  final DateTime? adExpiryDate;

  CreateCompanyParams({
    required this.id,
    required this.companyName,
    required this.ceoName,
    required this.phone,
    required this.address,
    required this.detailAddress,
    required this.category,
    required this.subcategory,
    this.website,
    this.greeting,
    required this.photos,
    this.logo,
    required this.adPayment,
    this.adExpiryDate,
  });
}