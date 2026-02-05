import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../data/models/post_model.dart';
import 'post_edit_view.dart';

class PostDetailView extends StatefulWidget {
  final PostEntity? post;
  final String? postId;

  const PostDetailView({
    super.key,
    this.post,
    this.postId,
  });

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  PostEntity? _post;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _post = widget.post;
      _isLoading = false;
    } else if (widget.postId != null) {
      _loadPost(widget.postId!);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '게시글 정보가 없습니다.';
      });
    }
  }

  Future<void> _loadPost(String postId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (!doc.exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = '게시글을 찾을 수 없습니다.';
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      // 이미지 데이터 디버그
      debugPrint('📸 게시글 이미지 데이터: ${data['images']}');
      debugPrint('📸 이미지 타입: ${data['images']?.runtimeType}');
      if (data['images'] != null && data['images'] is List) {
        debugPrint('📸 이미지 개수: ${(data['images'] as List).length}');
        debugPrint('📸 이미지 URL들: ${data['images']}');
      }
      
      // 조회수 증가 (FieldValue.increment 사용 - 동시성 안전)
      try {
        final currentViewCount = (data['viewCount'] as int?) ?? 0;
        debugPrint('📊 게시글 조회수 증가: $postId (현재: $currentViewCount)');
        
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({'viewCount': FieldValue.increment(1)});
        
        // 조회수 증가 반영 (현재 값 + 1)
        data['viewCount'] = currentViewCount + 1;
        debugPrint('✅ 조회수 증가 완료: ${currentViewCount + 1}');
      } catch (e) {
        // 조회수 증가 실패해도 게시글은 표시
        debugPrint('⚠️ 조회수 증가 실패: $e');
        // viewCount가 없을 수 있으므로 기본값 설정
        if (!data.containsKey('viewCount')) {
          data['viewCount'] = 0;
        }
      }
      
      final postModel = PostModel.fromJson(data);
      final post = postModel.toEntity();

      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '게시글을 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _post == null) {
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                _errorMessage ?? '게시글을 찾을 수 없습니다.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final post = _post!;
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
          onPressed: () {
            // 관리자 페이지에서 Navigator.push로 들어온 경우를 처리
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Navigator.pop이 불가능한 경우 (예: 웹 환경)
              try {
                context.pop();
              } catch (e) {
                // context.pop도 실패하면 Navigator.pop을 강제 시도
                Navigator.of(context).pop();
              }
            }
          },
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
            
            // 제목 (equipmentName이 있으면 우선 표시)
            Text(
              post.equipmentName ?? post.title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 이미지
            if (post.images.isNotEmpty) ...[
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = post.images[index];
                    debugPrint('🖼️ 이미지 로드 시도: $imageUrl (인덱스: $index)');
                    
                    // 이미지 URL 유효성 검사
                    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
                      debugPrint('⚠️ 유효하지 않은 이미지 URL: $imageUrl');
                      return Container(
                        width: 300.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.grey[200],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '유효하지 않은 이미지 URL',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Container(
                      width: 300.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              debugPrint('✅ 이미지 로드 완료: $imageUrl');
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('❌ 이미지 로드 실패: $imageUrl');
                            debugPrint('❌ 오류: $error');
                            debugPrint('❌ StackTrace: $stackTrace');
                            return Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 48.sp,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '이미지를 불러올 수 없습니다',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    child: Text(
                                      imageUrl.length > 30 
                                          ? '${imageUrl.substring(0, 30)}...'
                                          : imageUrl,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ] else ...[
              // 이미지가 없는 경우 디버그 정보 표시
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '등록된 이미지가 없습니다.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
