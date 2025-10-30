import '../../entities/company_entity.dart';
import '../../repositories/company_repository.dart';

class GetCompaniesUseCase {
  final CompanyRepository _companyRepository;

  GetCompaniesUseCase(this._companyRepository);

  Future<List<CompanyEntity>> call(GetCompaniesParams params) async {
    try {
      return await _companyRepository.getCompanies(
        category: params.category,
        subcategory: params.subcategory,
        subSubcategory: params.subSubcategory,
        region: params.region,
        limit: params.limit,
        orderBy: params.orderBy,
        descending: params.descending,
      );
    } catch (e) {
      throw Exception('기업 목록 조회 실패: ${e.toString()}');
    }
  }
}

class GetCompaniesParams {
  final String? category;
  final String? subcategory;
  final String? subSubcategory;
  final String? region;
  final int? limit;
  final String? orderBy;
  final bool descending;

  GetCompaniesParams({
    this.category,
    this.subcategory,
    this.subSubcategory,
    this.region,
    this.limit,
    this.orderBy,
    this.descending = false,
  });

  // 편의를 위한 팩토리 생성자들
  factory GetCompaniesParams.byCategory(String category, {int? limit}) {
    return GetCompaniesParams(
      category: category,
      limit: limit,
      orderBy: 'adPayment',
      descending: true, // 광고비 높은 순
    );
  }

  factory GetCompaniesParams.byRegion(String region, {int? limit}) {
    return GetCompaniesParams(
      region: region,
      limit: limit,
      orderBy: 'adPayment',
      descending: true, // 광고비 높은 순
    );
  }

  factory GetCompaniesParams.featured({int limit = 20}) {
    return GetCompaniesParams(
      limit: limit,
      orderBy: 'adPayment',
      descending: true, // 광고비 높은 순
    );
  }

  factory GetCompaniesParams.recent({int limit = 10}) {
    return GetCompaniesParams(
      limit: limit,
      orderBy: 'createdAt',
      descending: true, // 최신 순
    );
  }
}