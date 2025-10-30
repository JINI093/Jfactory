import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdmobInterstitialHelper {
  static AdmobInterstitialHelper? _instance;
  static AdmobInterstitialHelper get instance {
    _instance ??= AdmobInterstitialHelper._internal();
    return _instance!;
  }

  AdmobInterstitialHelper._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  // AdMob Unit IDs - 개발/프로덕션 환경 분리
  String get _adUnitId {
    if (kDebugMode) {
      // 테스트 광고 ID (개발 중)
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android 테스트 인터스티셜 ID
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트 인터스티셜 ID
    } else {
      // 실제 광고 ID (프로덕션) - 실제 ID가 필요합니다
      return Platform.isAndroid
          ? 'ca-app-pub-8455118855307052/[ANDROID_INTERSTITIAL_ID]' // Android 실제 ID
          : 'ca-app-pub-8455118855307052/[iOS_INTERSTITIAL_ID]'; // iOS 실제 ID
    }
  }

  Future<void> loadAd() async {
    if (_isLoading || _isAdLoaded) return;

    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('InterstitialAd loaded: $ad');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
          
          _setFullScreenCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          debugPrint('Error code: ${error.code}, Domain: ${error.domain}');
          _interstitialAd = null;
          _isAdLoaded = false;
          _isLoading = false;
        },
      ),
    );
  }

  void _setFullScreenCallback() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('InterstitialAd showed full screen content: $ad');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('InterstitialAd dismissed full screen content: $ad');
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        
        // 다음 광고 미리 로드
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('InterstitialAd failed to show full screen content: $ad, error: $error');
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
      },
    );
  }

  void showAd() {
    if (_interstitialAd == null) {
      debugPrint('InterstitialAd not loaded yet');
      // 광고가 로드되지 않았다면 로드 시도
      loadAd();
      return;
    }

    _interstitialAd!.show();
  }

  bool get isAdLoaded => _isAdLoaded;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }
}

// 인터스티셜 광고 표시 버튼 위젯
class AdmobInterstitialButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool showAdBeforeAction;

  const AdmobInterstitialButton({
    super.key,
    required this.child,
    this.onPressed,
    this.showAdBeforeAction = false,
  });

  @override
  State<AdmobInterstitialButton> createState() => _AdmobInterstitialButtonState();
}

class _AdmobInterstitialButtonState extends State<AdmobInterstitialButton> {
  @override
  void initState() {
    super.initState();
    // 미리 광고 로드
    AdmobInterstitialHelper.instance.loadAd();
  }

  void _handlePress() {
    if (widget.showAdBeforeAction) {
      // 액션 전에 광고 표시
      AdmobInterstitialHelper.instance.showAd();
      
      // 약간의 딜레이 후 액션 실행
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onPressed?.call();
      });
    } else {
      // 액션 후 광고 표시
      widget.onPressed?.call();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        AdmobInterstitialHelper.instance.showAd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handlePress,
      child: widget.child,
    );
  }
}