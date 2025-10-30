import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KakaoKeyHashHelper {
  static const MethodChannel _channel = MethodChannel('kakao_key_hash');

  /// Android 키해시를 가져와서 출력합니다
  static Future<void> printKeyHash() async {
    if (Platform.isAndroid) {
      try {
        final String keyHash = await _channel.invokeMethod('getKeyHash');
        debugPrint('🔑 카카오 개발자 콘솔에 등록해야 할 Android 키해시:');
        debugPrint('📋 키해시: $keyHash');
        debugPrint('🌐 카카오 개발자 콘솔 → 플랫폼 → Android → 키해시에 위 값을 등록하세요');
      } catch (e) {
        debugPrint('❌ 키해시 생성 실패: $e');
        debugPrint('💡 대안: 터미널에서 다음 명령어 실행');
        debugPrint('keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64');
      }
    } else {
      debugPrint('🍎 iOS 번들ID: com.sungmin.vendorads');
      debugPrint('📝 카카오 개발자 콘솔에서 iOS 플랫폼 번들ID가 정확한지 확인하세요');
    }
  }
}