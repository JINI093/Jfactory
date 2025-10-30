import '../../repositories/favorite_repository.dart';

class ToggleFavoriteUseCase {
  final FavoriteRepository _favoriteRepository;

  ToggleFavoriteUseCase(this._favoriteRepository);

  Future<bool> call(String userId, String companyId) async {
    try {
      final isFavorite = await _favoriteRepository.isFavorite(userId, companyId);
      
      if (isFavorite) {
        await _favoriteRepository.removeFavorite(userId, companyId);
        return false; // 제거됨
      } else {
        await _favoriteRepository.addFavorite(userId, companyId);
        return true; // 추가됨
      }
    } catch (e) {
      throw Exception('좋아요 토글 실패: ${e.toString()}');
    }
  }
}