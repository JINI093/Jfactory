import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 이 파일은 현재 사용되지 않습니다.
// 실제 Provider 설정은 app_providers.dart에서 관리됩니다.

class AuthProviders {
  // 레거시 코드 - 현재 사용되지 않음
  static List<ChangeNotifierProvider> get authProviders => [
    // MainViewModel은 이제 의존성 주입이 필요하므로 여기서 생성할 수 없음
    // 실제 Provider 설정은 AppProviders에서 처리됨
  ];

  static Widget wrapWithProviders(Widget child) {
    // 현재 사용되지 않음 - AppProviders 사용
    return child;
  }

  AuthProviders._();
}