import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80.sp,
              color: iconColor ?? Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: 32.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Pre-built empty states for common scenarios
class NoCompaniesFound extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoCompaniesFound({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '등록된 기업이 없습니다',
      message: '해당 카테고리에 등록된 기업이 없습니다.\n다른 카테고리를 확인해보세요.',
      icon: Icons.business_outlined,
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('새로고침'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
              ),
            )
          : null,
    );
  }
}

class NoFavoritesFound extends StatelessWidget {
  const NoFavoritesFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: '좋아요한 기업이 없습니다',
      message: '관심있는 기업에 좋아요를 눌러보세요.\n나중에 쉽게 찾을 수 있습니다.',
      icon: Icons.favorite_border,
      iconColor: Colors.red,
    );
  }
}

class NoInquiriesFound extends StatelessWidget {
  const NoInquiriesFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: '문의 내역이 없습니다',
      message: '궁금한 점이 있으시면\n언제든지 문의해주세요.',
      icon: Icons.help_outline,
    );
  }
}

class NoPaymentHistory extends StatelessWidget {
  const NoPaymentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: '결제 내역이 없습니다',
      message: '광고를 구매하시면\n결제 내역을 확인할 수 있습니다.',
      icon: Icons.payment_outlined,
    );
  }
}