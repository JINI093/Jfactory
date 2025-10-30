import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../services/in_app_purchase_service.dart';
import '../../../domain/entities/purchase_entity.dart' as entities;
import '../../../data/repositories/purchase_repository_impl.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AdPurchaseView extends StatefulWidget {
  const AdPurchaseView({super.key});

  @override
  State<AdPurchaseView> createState() => _AdPurchaseViewState();
}

class _AdPurchaseViewState extends State<AdPurchaseView> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  final PurchaseRepositoryImpl _purchaseRepository = PurchaseRepositoryImpl();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    await _purchaseService.initialize();
    
    _purchaseService.onPurchaseCompleted = (purchaseDetails) {
      _handlePurchaseCompleted(purchaseDetails);
    };
    
    _purchaseService.onPurchaseError = (purchaseDetails) {
      _handlePurchaseError(purchaseDetails);
    };
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handlePurchaseCompleted(PurchaseDetails purchaseDetails) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final authViewModel = context.read<AuthViewModel>();
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create purchase entity
      final purchase = entities.PurchaseEntity(
        id: purchaseDetails.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        companyId: authViewModel.currentUser?.companyName ?? 'unknown',
        purchaseType: _purchaseService.getAdTypeFromProductId(purchaseDetails.productID),
        amount: _purchaseService.getAmountFromProductId(purchaseDetails.productID),
        currency: 'KRW',
        status: entities.PurchaseStatus.completed,
        purchaseDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 30)), // 30 days validity
        productId: purchaseDetails.productID,
        transactionId: purchaseDetails.purchaseID,
        metadata: {
          'platform': 'flutter',
          'verificationData': purchaseDetails.verificationData.localVerificationData,
        },
      );

      // Save to Firebase
      await _purchaseRepository.createPurchase(purchase);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 구매가 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back after successful purchase
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구매 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구매 실패: ${purchaseDetails.error?.message ?? '알 수 없는 오류'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _purchaseAd(String productId) async {
    setState(() {
      _isLoading = true;
    });

    final success = await _purchaseService.purchaseProduct(productId);
    
    if (!success) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구매를 시작할 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 30.h),
                  _buildAdPackages(),
                  SizedBox(height: 30.h),
                  _buildBenefits(),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      title: Text(
        '광고 구매',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '광고 패키지 선택',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '귀하의 비즈니스를 더 많은 고객에게 노출시키세요',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAdPackages() {
    return Column(
      children: [
        _buildAdPackageCard(
          title: '기본 광고',
          price: '10,000원',
          duration: '30일',
          features: [
            '검색 결과 상단 노출',
            '기본 하이라이트 효과',
            '30일간 유효',
          ],
          productId: InAppPurchaseService.basicAdProductId,
          color: const Color(0xFF1E3A5F),
        ),
        SizedBox(height: 16.h),
        _buildAdPackageCard(
          title: '프리미엄 광고',
          price: '30,000원',
          duration: '30일',
          features: [
            '최상단 우선 노출',
            '프리미엄 배지 표시',
            '강화된 하이라이트',
            '분석 리포트 제공',
          ],
          productId: InAppPurchaseService.premiumAdProductId,
          color: const Color(0xFFFF9800),
          isPopular: true,
        ),
        SizedBox(height: 16.h),
        _buildAdPackageCard(
          title: '추천 광고',
          price: '50,000원',
          duration: '30일',
          features: [
            '메인 페이지 추천 섹션',
            '특별 배지 및 효과',
            '푸시 알림 포함',
            '상세 분석 리포트',
            '우선 고객 지원',
          ],
          productId: InAppPurchaseService.featuredAdProductId,
          color: const Color(0xFFE91E63),
        ),
      ],
    );
  }

  Widget _buildAdPackageCard({
    required String title,
    required String price,
    required String duration,
    required List<String> features,
    required String productId,
    required Color color,
    bool isPopular = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isPopular ? color : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.r),
                    bottomRight: Radius.circular(8.r),
                  ),
                ),
                child: Text(
                  '인기',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16.sp,
                            color: color,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            feature,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchaseAd(productId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      '구매하기',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '광고의 장점',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          _buildBenefitItem(
            icon: Icons.visibility,
            title: '노출 증가',
            description: '더 많은 고객이 귀하의 비즈니스를 발견할 수 있습니다',
          ),
          SizedBox(height: 12.h),
          _buildBenefitItem(
            icon: Icons.trending_up,
            title: '매출 향상',
            description: '높은 노출도로 인한 문의 및 매출 증가',
          ),
          SizedBox(height: 12.h),
          _buildBenefitItem(
            icon: Icons.analytics,
            title: '분석 리포트',
            description: '광고 성과를 측정하고 최적화할 수 있습니다',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}