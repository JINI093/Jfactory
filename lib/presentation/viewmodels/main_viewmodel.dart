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
  bool _isLoading = false;
  String? _error;
  
  List<CompanyEntity> get companies => _filteredCompanies.isNotEmpty ? _filteredCompanies : _companies;
  List<Map<String, String>> get selectedLocations => _selectedLocations;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSubcategory => _selectedSubcategory;
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
          subcategory != '전체' && subcategory != '전체 하위카테고리') {
        String normalize(String text) {
          return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
        }
        
        final normalizedCompany = normalize(company.subcategory);
        final normalizedSelected = normalize(subcategory);
        
        if (normalizedCompany != normalizedSelected) {
          return false;
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
  
  void toggleFavorite(String companyId) {
    // 즐겨찾기 기능은 나중에 구현
    debugPrint('Toggle favorite for company: $companyId');
    notifyListeners();
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
    _applyAllFilters();
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
          _selectedSubcategory != '전체' && _selectedSubcategory != '전체 하위카테고리') {
        String normalize(String text) {
          return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
        }
        
        final normalizedCompany = normalize(company.subcategory);
        final normalizedSelected = normalize(_selectedSubcategory!);
        
        if (normalizedCompany != normalizedSelected) {
          return false;
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
      
      return true;
    }).toList();
    
    debugPrint('🔥 MainViewModel: Filtered companies: ${_filteredCompanies.length} / ${_companies.length}');
  }
}