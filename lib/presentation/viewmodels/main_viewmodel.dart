import 'package:flutter/material.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/usecases/company/get_companies.dart';

class MainViewModel extends ChangeNotifier {
  final GetCompaniesUseCase _getCompaniesUseCase;
  
  List<CompanyEntity> _companies = [];
  List<CompanyEntity> _filteredCompanies = [];
  List<Map<String, String>> _selectedLocations = [];
  String? _selectedCategory;
  String? _selectedSubcategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  
  List<CompanyEntity> get companies => _filteredCompanies.isNotEmpty ? _filteredCompanies : _companies;
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
    _selectedSubcategory = subcategory;
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
        
        final normalizedCompany = normalize(company.category);
        final normalizedSelected = normalize(_selectedCategory!);
        
        if (normalizedCompany != normalizedSelected) {
          return false;
        }
      }
      
      // 세부카테고리 필터 적용
      if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty && 
          _selectedSubcategory != '전체') {
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
      
      // 검색어 필터링 (검색어가 있으면 다른 필터보다 우선)
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase().trim();
        if (searchLower.isEmpty) return true; // 빈 검색어는 모든 결과 표시
        
        final matchesSearch = 
            company.companyName.toLowerCase().contains(searchLower) ||
            company.category.toLowerCase().contains(searchLower) ||
            company.subcategory.toLowerCase().contains(searchLower) ||
            (company.subSubcategory?.toLowerCase().contains(searchLower) ?? false) ||
            (company.greeting?.toLowerCase().contains(searchLower) ?? false) ||
            company.address.toLowerCase().contains(searchLower) ||
            company.ceoName.toLowerCase().contains(searchLower) ||
            company.phone.toLowerCase().contains(searchLower);
        
        if (!matchesSearch) {
          debugPrint('🔍 검색어 불일치: "$searchLower" - 기업: ${company.companyName}');
          return false;
        }
        debugPrint('✅ 검색어 일치: "$searchLower" - 기업: ${company.companyName}');
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