import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40.sp,
            height: size ?? 40.sp,
            child: CircularProgressIndicator(
              color: color ?? const Color(0xFF1E3A5F),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const FullScreenLoading({
    super.key,
    this.message,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: LoadingWidget(
          message: message ?? '로딩 중...',
          color: Colors.white,
        ),
      ),
    );
  }
}

class InlineLoading extends StatelessWidget {
  final String? message;
  final double height;

  const InlineLoading({
    super.key,
    this.message,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      child: LoadingWidget(
        message: message,
        size: 24.sp,
      ),
    );
  }
}