import '../../entities/company_entity.dart';
import '../../repositories/favorite_repository.dart';

class GetFavoriteCompaniesUseCase {
  final FavoriteRepository _favoriteRepository;

  GetFavoriteCompaniesUseCase(this._favoriteRepository);

  Future<List<CompanyEntity>> call(String userId) async {
    try {
      return await _favoriteRepository.getFavoriteCompanies(userId);
    } catch (e) {
      throw Exception('좋아요 기업 목록 조회 실패: ${e.toString()}');
    }
  }
}