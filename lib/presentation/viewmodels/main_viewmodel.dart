import 'package:flutter/material.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/usecases/company/get_companies.dart';

class MainViewModel extends ChangeNotifier {
  final GetCompaniesUseCase _getCompaniesUseCase;
  
  // "기계제작(전체)"에 포함될 관련 카테고리들
  static const List<String> _machineRelatedCategoryTitles = [
    '기계제작\n(파트별)',
    '*금형/몰드\n*3D 프린터',
    '*표면처리\n*건조기\n(열,UV,LED)',
    '*Vision\n(비전)\n*Robot\n(무인화)',
  ];
  
  List<CompanyEntity> _companies = [];
  List<CompanyEntity> _filteredCompanies = [];
  List<Map<String, String>> _selectedLocations = [];
  String? _selectedCategory;
  String? _selectedSubcategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  
  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _selectedSubcategory != null ||
      _selectedLocations.isNotEmpty;

  List<CompanyEntity> get companies =>
      _hasActiveFilters ? _filteredCompanies : _companies;
  List<Map<String, String>> get selectedLocations => _selectedLocations;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSubcategory => _selectedSubcategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 필터된 기업 수를 반환 (카테고리와 지역 필터 적용 시)
  int getFilteredCount({
    String? category,
    String? subcategory,
    List<Map<String, String>>? locations,
  }) {
    return _companies.where((company) {
      // 카테고리 필터 적용
      if (category != null && category.isNotEmpty) {
        String normalize(String text) {
          return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
        }
        
        final normalizedCompany = normalize(company.category);
        final normalizedSelected = normalize(category);
        
        if (normalizedCompany != normalizedSelected) {
          return false;
        }
      }
      
      // 세부카테고리 필터 적용
      if (subcategory != null && subcategory.isNotEmpty && 
          subcategory != '전체') {
        // "전체 하위카테고리" 선택 시 해당 카테고리의 모든 하위 카테고리 포함
        if (subcategory == '전체 하위카테고리') {
          // 메인 카테고리만 필터링 (모든 하위 카테고리 포함)
          // 이미 위에서 카테고리 필터가 적용되었으므로 여기서는 추가 필터링 불필요
        } else {
          // 특정 세부카테고리 선택 시
          String normalize(String text) {
            return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
          }
          
          final normalizedCompany = normalize(company.subcategory);
          final normalizedSelected = normalize(subcategory);
          
          // 정확한 매칭 또는 포함 관계 확인
          if (normalizedCompany != normalizedSelected && 
              !normalizedCompany.contains(normalizedSelected) &&
              !normalizedSelected.contains(normalizedCompany)) {
            return false;
          }
        }
      }
      
      // 지역 필터 적용
      if (locations != null && locations.isNotEmpty) {
        final companyAddress = company.address;
        final matchesLocation = locations.any((location) {
          final selectedRegion = location['region'];
          final selectedDistrict = location['district'];
          
          if (selectedRegion == null) return false;
          
          if (selectedDistrict == '전체' || selectedDistrict == '전지역') {
            return companyAddress.contains(selectedRegion);
          }
          
          return companyAddress.contains(selectedRegion) && 
                 (selectedDistrict == null || companyAddress.contains(selectedDistrict));
        });
        
        if (!matchesLocation) return false;
      }
      
      return true;
    }).length;
  }
  
  MainViewModel({
    required GetCompaniesUseCase getCompaniesUseCase,
  }) : _getCompaniesUseCase = getCompaniesUseCase;
  
  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 실제 Firestore에서 기업 데이터 가져오기 (더 많이 가져와서 필터링 가능하도록)
      _companies = await _getCompaniesUseCase.call(
        GetCompaniesParams.featured(limit: 200),
      );
      
      debugPrint('🔥 MainViewModel: Loaded ${_companies.length} companies');
      
      // 필터 적용
      _applyAllFilters();
    } catch (e) {
      _error = e.toString();
      _companies = []; // 오류 발생 시 빈 리스트
      _filteredCompanies = [];
      debugPrint('🔥 MainViewModel Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  

  void updateLocationFilter(List<Map<String, String>> locations) {
    _selectedLocations = locations;
    _applyAllFilters();
    notifyListeners();
  }

  void updateCategoryFilter(String? category, String? subcategory) {
    _selectedCategory = category;
    if (subcategory == null ||
        subcategory == '전체' ||
        subcategory == '전체 하위카테고리') {
      _selectedSubcategory = null;
    } else {
      _selectedSubcategory = subcategory;
    }
    _applyAllFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedLocations = [];
    _selectedCategory = null;
    _selectedSubcategory = null;
    _searchQuery = '';
    _applyAllFilters();
    notifyListeners();
  }

  void searchCompanies(String query) {
    final trimmedQuery = query.trim();
    debugPrint('🔍 searchCompanies called with query: "$trimmedQuery"');
    _searchQuery = trimmedQuery;
    _applyAllFilters();
    debugPrint('🔍 After filtering: ${_filteredCompanies.length} companies found');
    notifyListeners();
  }

  void _applyAllFilters() {
    _filteredCompanies = _companies.where((company) {
      // 카테고리 필터 적용
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        String normalize(String text) {
          return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
        }
        
        bool isMachineManufacturingAll(String category) {
          final normalized = normalize(category);
          return normalized.contains('기계제작') && normalized.contains('전체');
        }
        
        bool isMachineManufacturingRelated(String category) {
          final normalizedCompany = normalize(category);
          if (normalizedCompany.contains('mall')) {
            return false;
          }
          if (normalizedCompany.contains('기계제작') || normalizedCompany.contains('기계 제작')) {
            return true;
          }
          final normalizedSet = _machineRelatedCategoryTitles
              .map((title) => normalize(title))
              .toSet();
          return normalizedSet.any((title) => normalizedCompany.contains(title));
        }
        
        final normalizedCompany = normalize(company.category);
        final normalizedSelected = normalize(_selectedCategory!);
        
        // "기계제작(전체)" 선택 시 관련 카테고리 전체 포함 (MALL 제외)
        if (isMachineManufacturingAll(_selectedCategory!)) {
          if (!isMachineManufacturingRelated(company.category)) {
            return false;
          }
        } else {
          // 정확한 매칭
          if (normalizedCompany != normalizedSelected) {
            return false;
          }
        }
      }
      
      // 세부카테고리 필터 적용
      if (_selectedSubcategory != null &&
          _selectedSubcategory!.isNotEmpty &&
          _selectedSubcategory != '전체' &&
          _selectedSubcategory != '전체 하위카테고리') {
        // "전체 하위카테고리" 선택 시 해당 카테고리의 모든 하위 카테고리 포함
        if (_selectedSubcategory == '전체 하위카테고리') {
          // 메인 카테고리만 필터링 (모든 하위 카테고리 포함)
          // 이미 위에서 카테고리 필터가 적용되었으므로 여기서는 추가 필터링 불필요
        } else {
          // 특정 세부카테고리 선택 시
          String normalize(String text) {
            return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
          }
          
          final normalizedCompany = normalize(company.subcategory);
          final normalizedSelected = normalize(_selectedSubcategory!);
          
          // 정확한 매칭 또는 포함 관계 확인
          if (normalizedCompany != normalizedSelected && 
              !normalizedCompany.contains(normalizedSelected) &&
              !normalizedSelected.contains(normalizedCompany)) {
            return false;
          }
        }
      }
      
      // 지역 필터 적용
      if (_selectedLocations.isNotEmpty) {
        final companyAddress = company.address;
        final matchesLocation = _selectedLocations.any((location) {
          final selectedRegion = location['region'];
          final selectedDistrict = location['district'];
          
          if (selectedRegion == null) return false;
          
          if (selectedDistrict == '전체' || selectedDistrict == '전지역') {
            return companyAddress.contains(selectedRegion);
          }
          
          return companyAddress.contains(selectedRegion) && 
                 (selectedDistrict == null || companyAddress.contains(selectedDistrict));
        });
        
        if (!matchesLocation) return false;
      }
      
      // 검색어 필터링 (카테고리/서브카테고리/서브서브카테고리에서만 검색)
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase().trim();
        if (searchLower.isEmpty) return true; // 빈 검색어는 모든 결과 표시
        
        // 카테고리 필드에서 검색 (정확한 단어 매칭)
        final categoryText = company.category.toLowerCase();
        final subcategoryText = company.subcategory.toLowerCase();
        final subSubcategoryText = (company.subSubcategory ?? '').toLowerCase();
        
        // 카테고리, 서브카테고리, 서브서브카테고리에서 검색어가 포함되어 있는지 확인
        // 줄바꿈과 특수문자를 제거하고 단어 단위로 검색
        String normalizeForSearch(String text) {
          return text
              .replaceAll('\n', ' ')
              .replaceAll('*', '')
              .replaceAll('(', ' ')
              .replaceAll(')', ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim()
              .toLowerCase();
        }
        
        final normalizedCategory = normalizeForSearch(categoryText);
        final normalizedSubcategory = normalizeForSearch(subcategoryText);
        final normalizedSubSubcategory = normalizeForSearch(subSubcategoryText);
        
        // 영어/한글 매칭을 위한 검색어 변형
        final searchVariants = [
          searchLower,
          // 한글 -> 영어 변환 (간단한 매핑)
          if (searchLower == '로봇') 'robot',
          if (searchLower == 'robot') '로봇',
          if (searchLower == '모터') 'motor',
          if (searchLower == 'motor') '모터',
        ];
        
        // 검색어가 카테고리 필드 중 하나에 포함되어 있는지 확인
        final matchesWithVariants = searchVariants.any((variant) =>
            normalizedCategory.contains(variant) ||
            normalizedSubcategory.contains(variant) ||
            normalizedSubSubcategory.contains(variant));
        
        if (!matchesWithVariants) {
          debugPrint('❌ 검색어 불일치: "$searchLower" - 기업: ${company.companyName}, 카테고리: $categoryText, 서브카테고리: $subcategoryText');
          return false;
        }
        debugPrint('✅ 검색어 일치: "$searchLower" - 기업: ${company.companyName}, 카테고리: $categoryText, 서브카테고리: $subcategoryText');
      }
      
      return true;
    }).toList();
    
    debugPrint('🔥 MainViewModel: Filtered companies: ${_filteredCompanies.length} / ${_companies.length}');
    if (_searchQuery.isNotEmpty) {
      debugPrint('🔍 Search query: "$_searchQuery"');
      debugPrint('🔍 Filtered companies: ${_filteredCompanies.map((c) => c.companyName).join(", ")}');
    }
  }
}