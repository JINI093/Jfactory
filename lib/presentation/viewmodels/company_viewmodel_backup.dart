import 'package:flutter/material.dart';

class CompanyViewModel extends ChangeNotifier {
  Map<String, dynamic>? _selectedCompany;
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? get selectedCompany => _selectedCompany;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadCompany(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulate loading company details
      await Future.delayed(const Duration(seconds: 1));
      _selectedCompany = {
        'id': companyId,
        'name': 'Company Name',
        'category': 'Category',
        'location': 'Location',
        'equipment': 'Equipment',
        'manufacturer': 'Manufacturer',
        'model': 'Model',
        'specifications': {
          'x': '4200',
          'y': '2800',
          'z': '1000',
          'angle': '10',
          'tableSize': '2040 X 4200',
          'features': 'CNC',
          'quantity': '2',
        },
        'isFavorite': true,
        'imageUrl': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void toggleFavorite() {
    if (_selectedCompany != null) {
      _selectedCompany!['isFavorite'] = !_selectedCompany!['isFavorite'];
      notifyListeners();
    }
  }
}