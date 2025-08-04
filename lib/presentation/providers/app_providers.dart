import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(create: (_) => MainViewModel()),
  ];
  
  AppProviders._();
}