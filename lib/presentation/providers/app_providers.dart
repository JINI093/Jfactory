import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/main_viewmodel.dart';
import '../viewmodels/company_viewmodel.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(create: (_) => MainViewModel()),
    ChangeNotifierProvider(create: (_) => CompanyViewModel()),
  ];
  
  AppProviders._();
}