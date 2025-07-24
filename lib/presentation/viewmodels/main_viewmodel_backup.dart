import 'package:flutter/material.dart';

class MainViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _companies = [];
  bool _isLoading = false;
  String? _error;
  
  List<Map<String, dynamic>> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  MainViewModel() {
    loadCompanies();
  }
  
  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate loading companies
      await Future.delayed(const Duration(seconds: 1));
      _companies = [
        {
          'id': '1',
          'name': 'Company Name',
          'category': 'Category',
          'location': 'Location',
          'equipment': 'Equipment',
          'manufacturer': 'HARTFORD',
          'model': 'PRW-426L',
          'isFavorite': true,
        },
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void toggleFavorite(String companyId) {
    final index = _companies.indexWhere((company) => company['id'] == companyId);
    if (index != -1) {
      _companies[index]['isFavorite'] = !_companies[index]['isFavorite'];
      notifyListeners();
    }
  }
}