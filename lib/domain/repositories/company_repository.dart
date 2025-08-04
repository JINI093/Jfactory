import '../entities/company_entity.dart';

abstract class CompanyRepository {
  Future<void> createCompany(CompanyEntity company);
  Future<CompanyEntity?> getCompany(String companyId);
  Future<List<CompanyEntity>> getCompanies({
    String? category,
    String? subcategory,
    String? region,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<void> updateCompany(CompanyEntity company);
  Future<void> deleteCompany(String companyId);
  Future<List<CompanyEntity>> searchCompanies(String query);
  Future<List<CompanyEntity>> getCompaniesByCategory(String category);
  Future<List<CompanyEntity>> getCompaniesByRegion(String region);
  Future<List<CompanyEntity>> getFeaturedCompanies();
}