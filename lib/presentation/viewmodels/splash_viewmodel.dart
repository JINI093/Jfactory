import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  SplashViewModel() {
    // SplashViewModel initialized
  }
  
  void setInitialized() {
    _isInitialized = true;
    notifyListeners();
  }
}