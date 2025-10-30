import '../entities/company_entity.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite(String userId, String companyId);
  Future<void> removeFavorite(String userId, String companyId);
  Future<List<CompanyEntity>> getFavoriteCompanies(String userId);
  Future<bool> isFavorite(String userId, String companyId);
}