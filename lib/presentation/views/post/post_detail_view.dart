import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/post_entity.dart';
import 'post_edit_view.dart';

class PostDetailView extends StatelessWidget {
  final PostEntity post;

  const PostDetailView({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '게시글 상세',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostEditView(post: post),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시글 상태 및 프리미엄 표시
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(post.status),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getStatusText(post.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (post.isPremium) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '프리미엄',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 제목
            Text(
              post.title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 이미지
            if (post.images.isNotEmpty) ...[
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    post.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48.sp,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 장비 정보 카드
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '장비 정보',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  if (post.equipmentName != null) ...[
                    _buildInfoRow('장비명', post.equipmentName!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.manufacturer != null) ...[
                    _buildInfoRow('제조사', post.manufacturer!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.model != null) ...[
                    _buildInfoRow('모델', post.model!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.category != null) ...[
                    _buildInfoRow('카테고리', post.category!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.subcategory != null) ...[
                    _buildInfoRow('세부카테고리', post.subcategory!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.subSubcategory != null) ...[
                    _buildInfoRow('세부카테고리', post.subSubcategory!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.quantity != null) ...[
                    _buildInfoRow('수량', post.quantity!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.weight != null) ...[
                    _buildInfoRow('중량', '${post.weight}kg'),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.tableSize != null) ...[
                    _buildInfoRow('테이블 크기', post.tableSize!),
                    SizedBox(height: 8.h),
                  ],
                  
                  if (post.dimensionX != null && post.dimensionY != null && post.dimensionZ != null) ...[
                    _buildInfoRow('치수', '${post.dimensionX} × ${post.dimensionY} × ${post.dimensionZ}mm'),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 특징 및 상세 정보
            if (post.features != null && post.features!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '특징',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      post.features!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 내용
            if (post.content.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '상세 내용',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // 게시글 정보
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '게시글 정보',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildInfoRow('조회수', '${post.viewCount}'),
                  SizedBox(height: 4.h),
                  _buildInfoRow('작성일', _formatDate(post.createdAt)),
                  if (post.updatedAt != null) ...[
                    SizedBox(height: 4.h),
                    _buildInfoRow('수정일', _formatDate(post.updatedAt!)),
                  ],
                  if (post.isPremium && post.premiumExpiryDate != null) ...[
                    SizedBox(height: 4.h),
                    _buildInfoRow('프리미엄 만료일', _formatDate(post.premiumExpiryDate!)),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return '임시저장';
      case PostStatus.published:
        return '게시중';
      case PostStatus.hidden:
        return '숨김';
      case PostStatus.deleted:
        return '삭제됨';
    }
  }

  Color _getStatusColor(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return Colors.grey;
      case PostStatus.published:
        return Colors.green;
      case PostStatus.deleted:
        return Colors.grey;
      case PostStatus.hidden:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
