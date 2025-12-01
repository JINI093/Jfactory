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
  String? _selectedSubSubcategory;
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
  String? get selectedSubSubcategory => _selectedSubSubcategory;
  String? get selectedRegion => _selectedRegion;
  String get searchQuery => _searchQuery;

  // Load companies by category
  Future<void> loadCompaniesByCategory(String category, {String? subcategory, String? subSubcategory}) async {
    _loadingState = CompanyLoadingState.loading;
    _errorMessage = null;
    _selectedCategory = category;
    _selectedSubcategory = subcategory;
    _selectedSubSubcategory = subSubcategory;
    notifyListeners();

    try {
      // limit을 크게 설정하여 클라이언트에서 필터링할 수 있도록 충분히 가져옴
      final allCompanies = await _getCompaniesUseCase(GetCompaniesParams(
        category: category,
        subcategory: subcategory,
        limit: 200, // 충분히 많이 가져옴
        orderBy: 'adPayment',
        descending: true,
      ));

      _companies = allCompanies;
      debugPrint('🔥 CompanyViewModel: Loaded ${_companies.length} companies');
      debugPrint('🔥 선택된 카테고리: category="$category", subcategory="$subcategory", subSubcategory="$subSubcategory"');
      
      // 필터링된 기업들 (카테고리 필터 적용)
      _applyFilters();
      debugPrint('🔥 CompanyViewModel: Filtered companies: ${_filteredCompanies.length}');
      
      // 필터링 후 limit 적용 (최대 50개)
      if (_filteredCompanies.length > 50) {
        _filteredCompanies = _filteredCompanies.take(50).toList();
      }
      
      // 프리미엄 기업들 (필터링된 기업 중 광고비가 높은 상위 기업들)
      _premiumCompanies = _filteredCompanies
          .where((company) => company.adPayment > 0)
          .take(9)
          .toList();
      
      debugPrint('🔥 CompanyViewModel: Premium companies: ${_premiumCompanies.length}');
      
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
      // 카테고리 필터링
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        final companyCategory = company.category.trim();
        final selectedCategory = _selectedCategory!.trim();
        
        // 정규화 함수: 줄바꿈을 공백으로, 연속 공백 정리, 소문자 변환
        String normalize(String text) {
          return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
        }
        
        final normalizedCompany = normalize(companyCategory);
        final normalizedSelected = normalize(selectedCategory);
        
        // 정확한 매칭 (대소문자 무시, 공백 정규화)
        if (normalizedCompany != normalizedSelected) {
          debugPrint('카테고리 불일치: company="$companyCategory" selected="$selectedCategory"');
          return false;
        }
      }
      
      // 세부카테고리 필터링
      if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty) {
        final companySubcategory = company.subcategory.trim();
        final selectedSubcategory = _selectedSubcategory!.trim();
        
        // 정규화 함수
        String normalize(String text) {
          return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
        }
        
        final normalizedCompany = normalize(companySubcategory);
        final normalizedSelected = normalize(selectedSubcategory);
        
        // 정확한 매칭
        if (normalizedCompany != normalizedSelected) {
          debugPrint('세부카테고리 불일치: company="$companySubcategory" selected="$selectedSubcategory"');
          return false;
        }
      }
      
      // 3차 세부카테고리 필터링
      if (_selectedSubSubcategory != null && _selectedSubSubcategory!.isNotEmpty) {
        final companySubSubcategory = (company.subSubcategory ?? '').trim();
        final selectedSubSubcategory = _selectedSubSubcategory!.trim();
        
        if (companySubSubcategory.isEmpty || companySubSubcategory.trim() != selectedSubSubcategory.trim()) {
          return false;
        }
      }
      
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
    
    debugPrint('🔍 필터 적용 결과: 전체 ${_companies.length}개 -> 필터링 ${_filteredCompanies.length}개');

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