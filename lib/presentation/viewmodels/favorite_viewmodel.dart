import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/usecases/favorite/get_favorite_companies.dart';
import '../../domain/usecases/favorite/toggle_favorite.dart';

class FavoriteViewModel extends ChangeNotifier {
  final GetFavoriteCompaniesUseCase _getFavoriteCompaniesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  List<CompanyEntity> _favoriteCompanies = [];
  bool _isLoading = false;
  String? _error;

  List<CompanyEntity> get favoriteCompanies => _favoriteCompanies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FavoriteViewModel({
    required GetFavoriteCompaniesUseCase getFavoriteCompaniesUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  }) : _getFavoriteCompaniesUseCase = getFavoriteCompaniesUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase;

  Future<void> loadFavoriteCompanies() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _favoriteCompanies = [];
      _error = '로그인이 필요합니다.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favoriteCompanies = await _getFavoriteCompaniesUseCase.call(currentUser.uid);
      debugPrint('FavoriteViewModel: loaded ${_favoriteCompanies.length} favorites');
    } catch (e) {
      _error = e.toString();
      _favoriteCompanies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(String companyId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }

    try {
      final result = await _toggleFavoriteUseCase.call(currentUser.uid, companyId);
      debugPrint('FavoriteViewModel: toggleFavorite result=$result for companyId=$companyId');
      // 좋아요 상태 변경 후 목록 새로고침
      await loadFavoriteCompanies();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  bool isFavorite(String companyId) {
    return _favoriteCompanies.any((company) => company.id == companyId);
  }

  Future<void> removeFavorite(String companyId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await _toggleFavoriteUseCase.call(currentUser.uid, companyId);
      // 좋아요 제거 후 목록 새로고침
      await loadFavoriteCompanies();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}