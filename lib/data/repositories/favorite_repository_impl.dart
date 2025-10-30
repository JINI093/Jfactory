import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FirestoreDataSource _firestoreDataSource;

  FavoriteRepositoryImpl({
    required FirestoreDataSource firestoreDataSource,
  }) : _firestoreDataSource = firestoreDataSource;

  @override
  Future<void> addFavorite(String userId, String companyId) async {
    try {
      final favoriteId = '${userId}_$companyId';
      final favorite = FavoriteModel(
        id: favoriteId,
        userId: userId,
        companyId: companyId,
        createdAt: DateTime.now(),
      );
      await _firestoreDataSource.addFavorite(favorite);
    } catch (e) {
      throw Exception('좋아요 추가 실패: $e');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String companyId) async {
    try {
      await _firestoreDataSource.removeFavorite(userId, companyId);
    } catch (e) {
      throw Exception('좋아요 제거 실패: $e');
    }
  }

  @override
  Future<List<CompanyEntity>> getFavoriteCompanies(String userId) async {
    try {
      final favorites = await _firestoreDataSource.getFavoritesByUser(userId);
      final companies = <CompanyEntity>[];
      
      // 각 좋아요된 기업의 정보를 가져옴
      for (final favorite in favorites) {
        try {
          final company = await _firestoreDataSource.getCompany(favorite.companyId);
          if (company != null) {
            companies.add(company.toEntity());
          }
        } catch (e) {
          // 개별 기업 조회 실패는 무시하고 계속 진행
          continue;
        }
      }
      
      return companies;
    } catch (e) {
      throw Exception('좋아요 기업 목록 조회 실패: $e');
    }
  }

  @override
  Future<bool> isFavorite(String userId, String companyId) async {
    try {
      return await _firestoreDataSource.isFavorite(userId, companyId);
    } catch (e) {
      throw Exception('좋아요 상태 확인 실패: $e');
    }
  }
}