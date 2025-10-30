import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdmobBannerWidget extends StatefulWidget {
  const AdmobBannerWidget({super.key});

  @override
  State<AdmobBannerWidget> createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<AdmobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // AdMob Unit IDs - 개발/프로덕션 환경 분리
  String get _adUnitId {
    if (kDebugMode) {
      // 테스트 광고 ID (개발 중)
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android 테스트 배너 ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 배너 ID
    } else {
      // 실제 광고 ID (프로덕션)
      return Platform.isAndroid
          ? 'ca-app-pub-8455118855307052/9587930923' // Android 실제 ID
          : 'ca-app-pub-8455118855307052/9587930923'; // iOS 실제 ID (동일)
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: const AdSize(width: 393, height: 100),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          debugPrint('Error code: ${error.code}, Domain: ${error.domain}');
          ad.dispose();
          setState(() {
            _bannerAd = null;
          });
        },
        onAdOpened: (ad) {
          debugPrint('BannerAd opened.');
        },
        onAdClosed: (ad) {
          debugPrint('BannerAd closed.');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // 광고 로딩 실패 시 빈 컨테이너
    if (_bannerAd == null) {
      return Container(
        width: 393.0,
        height: 100.0,
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.ad_units_outlined,
                color: Colors.grey[400],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                kDebugMode ? '테스트 광고 로딩 실패' : '광고 로딩 실패',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 광고 로딩 중 플레이스홀더
    return Container(
      width: 393.0,
      height: 100.0,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 8),
            Text(
              kDebugMode ? '테스트 광고 로딩 중...' : '광고 로딩 중...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}