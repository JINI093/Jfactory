import 'package:flutter/material.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/usecases/company/get_companies.dart';
import '../../domain/usecases/company/get_company_by_id.dart';
import '../../data/models/category_model.dart';

enum CompanyLoadingState {
  initial,
  loading,
  success,
  error,
}

class CompanyViewModel extends ChangeNotifier {
  final GetCompaniesUseCase _getCompaniesUseCase;
  final GetCompanyByIdUseCase _getCompanyByIdUseCase;

  CompanyViewModel({
    required GetCompaniesUseCase getCompaniesUseCase,
    required GetCompanyByIdUseCase getCompanyByIdUseCase,
  })  : _getCompaniesUseCase = getCompaniesUseCase,
        _getCompanyByIdUseCase = getCompanyByIdUseCase;

  // State
  CompanyLoadingState _loadingState = CompanyLoadingState.initial;
  List<CompanyEntity> _companies = [];
  List<CompanyEntity> _premiumCompanies = [];
  List<CompanyEntity> _filteredCompanies = [];
  CompanyEntity? _selectedCompany;
  String? _errorMessage;
  
  // Filters
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedRegion;
  String _searchQuery = '';
  
  // Getters
  CompanyLoadingState get loadingState => _loadingState;
  List<CompanyEntity> get companies => _filteredCompanies;
  List<CompanyEntity> get premiumCompanies => _premiumCompanies;
  CompanyEntity? get selectedCompany => _selectedCompany;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == CompanyLoadingState.loading;
  
  String? get selectedCategory => _selectedCategory;
  String? get selectedSubcategory => _selectedSubcategory;
  String? get selectedRegion => _selectedRegion;
  String get searchQuery => _searchQuery;

  // Load companies by category
  Future<void> loadCompaniesByCategory(String category, {String? subcategory}) async {
    _loadingState = CompanyLoadingState.loading;
    _errorMessage = null;
    _selectedCategory = category;
    _selectedSubcategory = subcategory;
    notifyListeners();

    try {
      final allCompanies = await _getCompaniesUseCase(GetCompaniesParams(
        category: category,
        subcategory: subcategory,
        limit: 50,
        orderBy: 'adPayment',
        descending: true,
      ));

      _companies = allCompanies;
      
      // 프리미엄 기업들 (광고비가 높은 상위 기업들)
      _premiumCompanies = allCompanies
          .where((company) => company.adPayment > 0)
          .take(9)
          .toList();
      
      // 필터링된 기업들
      _applyFilters();
      
      _loadingState = CompanyLoadingState.success;
    } catch (e) {
      _loadingState = CompanyLoadingState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  // Load company by ID
  Future<void> loadCompanyById(String companyId) async {
    _loadingState = CompanyLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCompany = await _getCompanyByIdUseCase(companyId);
      _loadingState = CompanyLoadingState.success;
    } catch (e) {
      _loadingState = CompanyLoadingState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  // Search companies
  void searchCompanies(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to companies
  void _applyFilters() {
    _filteredCompanies = _companies.where((company) {
      // 검색어 필터링
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final matchesSearch = company.companyName.toLowerCase().contains(searchLower) ||
                            company.category.toLowerCase().contains(searchLower) ||
                            company.subcategory.toLowerCase().contains(searchLower) ||
                            (company.greeting?.toLowerCase().contains(searchLower) ?? false);
        if (!matchesSearch) return false;
      }

      // 지역 필터링
      if (_selectedRegion != null && _selectedRegion!.isNotEmpty) {
        if (!company.address.contains(_selectedRegion!)) return false;
      }

      return true;
    }).toList();

    // 정렬: 프리미엄(광고비 높은 순) -> 일반(최신순)
    _filteredCompanies.sort((a, b) {
      // 먼저 광고비로 정렬
      if (a.adPayment != b.adPayment) {
        return b.adPayment.compareTo(a.adPayment);
      }
      // 광고비가 같으면 생성일로 정렬
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // Set region filter
  void setRegionFilter(String? region) {
    _selectedRegion = region;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters  
  void clearFilters() {
    _selectedRegion = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Get subcategories for current category
  List<String> getSubcategoriesForCategory() {
    if (_selectedCategory == null) return [];
    
    final category = CategoryData.getCategoryByTitle(_selectedCategory!);
    return category?.subcategories ?? [];
  }

  // Filter by subcategory
  void filterBySubcategory(String subcategory) {
    loadCompaniesByCategory(_selectedCategory!, subcategory: subcategory);
  }

  // Refresh data
  Future<void> refresh() async {
    if (_selectedCategory != null) {
      await loadCompaniesByCategory(_selectedCategory!, subcategory: _selectedSubcategory);
    }
  }

  // Toggle favorite (추후 구현)
  // Load single company by ID
  Future<void> loadCompany(String companyId) async {
    _loadingState = CompanyLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final company = await _getCompanyByIdUseCase.call(companyId);
      _selectedCompany = company;
      _loadingState = CompanyLoadingState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _loadingState = CompanyLoadingState.error;
      debugPrint('Error loading company: $e');
    }
    notifyListeners();
  }

  void toggleFavorite(String companyId) {
    // TODO: Implement favorite functionality
    // 즐겨찾기 기능은 사용자 계정과 연동하여 추후 구현
    debugPrint('Toggle favorite for company: $companyId');
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Error getter for convenience
  String? get error => _errorMessage;

  // Get premium companies count
  int get premiumCompaniesCount => _premiumCompanies.length;

  // Get general companies (non-premium)
  List<CompanyEntity> get generalCompanies {
    return _filteredCompanies
        .where((company) => company.adPayment == 0)
        .toList();
  }
}