import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// View Models
import '../viewmodels/main_viewmodel.dart';

class AuthProviders {
  static List<ChangeNotifierProvider> get authProviders => [
    ChangeNotifierProvider(create: (_) => MainViewModel()),
  ];

  static Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: authProviders,
      child: child,
    );
  }

  AuthProviders._();
}