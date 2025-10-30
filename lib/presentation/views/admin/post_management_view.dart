import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostManagementView extends StatefulWidget {
  const PostManagementView({super.key});

  @override
  State<PostManagementView> createState() => _PostManagementViewState();
}

class _PostManagementViewState extends State<PostManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '게시글 관리',
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 필터 및 검색
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.grey[50],
            child: Column(
              children: [
                // 검색바
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '제목, 내용으로 검색...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                SizedBox(height: 12.h),
                
                // 상태 필터
                Row(
                  children: [
                    Text(
                      '상태: ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('전체')),
                          DropdownMenuItem(value: 'draft', child: Text('임시저장')),
                          DropdownMenuItem(value: 'published', child: Text('게시중')),
                          DropdownMenuItem(value: 'hidden', child: Text('숨김')),
                          DropdownMenuItem(value: 'deleted', child: Text('삭제됨')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 게시글 목록
          Expanded(
            child: _buildPostList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    Query query = _firestore.collection('posts');

    // 상태 필터 적용
    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    // 최신순 정렬
    query = query.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '게시글 목록을 불러오는 중 오류가 발생했습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data?.docs ?? [];
        
        // 검색 필터 적용
        final filteredPosts = posts.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final content = data['content']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return title.contains(query) || content.contains(query);
        }).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  _searchQuery.isEmpty ? '등록된 게시글이 없습니다.' : '검색 결과가 없습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            final postDoc = filteredPosts[index];
            final postData = postDoc.data() as Map<String, dynamic>;
            
            return _buildPostCard(postDoc.id, postData);
          },
        );
      },
    );
  }

  Widget _buildPostCard(String postId, Map<String, dynamic> postData) {
    final title = postData['title'] ?? '제목 없음';
    final content = postData['content'] ?? '';
    final status = postData['status'] ?? 'draft';
    final createdAt = postData['createdAt'] as Timestamp?;
    final viewCount = postData['viewCount'] ?? 0;
    final isPremium = postData['isPremium'] ?? false;
    final images = List<String>.from(postData['images'] ?? []);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 이미지
                if (images.isNotEmpty) ...[
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Image.network(
                        images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPremium) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '프리미엄',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        content.length > 100 ? '${content.substring(0, 100)}...' : content,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.visibility,
                  size: 14.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 2.w),
                Text(
                  '$viewCount',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  createdAt != null
                      ? _formatDate(createdAt.toDate())
                      : '날짜 정보 없음',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showPostDetails(postId, postData),
                  child: Text(
                    '상세보기',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (status == 'draft') ...[
                  TextButton(
                    onPressed: () => _updatePostStatus(postId, 'published'),
                    child: Text(
                      '승인',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
                if (status == 'published') ...[
                  TextButton(
                    onPressed: () => _updatePostStatus(postId, 'hidden'),
                    child: Text(
                      '숨김',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () => _updatePostStatus(postId, 'deleted'),
                  child: Text(
                    '삭제',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'published':
        return Colors.green;
      case 'hidden':
        return Colors.orange;
      case 'deleted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'draft':
        return '임시저장';
      case 'published':
        return '게시중';
      case 'hidden':
        return '숨김';
      case 'deleted':
        return '삭제됨';
      default:
        return '알 수 없음';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showPostDetails(String postId, Map<String, dynamic> postData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('게시글 상세 정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('제목', postData['title'] ?? '정보 없음'),
              _buildDetailRow('내용', postData['content'] ?? '정보 없음'),
              _buildDetailRow('상태', _getStatusText(postData['status'] ?? 'unknown')),
              _buildDetailRow('조회수', '${postData['viewCount'] ?? 0}'),
              _buildDetailRow('프리미엄', postData['isPremium'] == true ? '예' : '아니오'),
              if (postData['category'] != null)
                _buildDetailRow('카테고리', postData['category']),
              if (postData['equipmentName'] != null)
                _buildDetailRow('장비명', postData['equipmentName']),
              _buildDetailRow(
                '작성일',
                postData['createdAt'] != null
                    ? _formatDate((postData['createdAt'] as Timestamp).toDate())
                    : '정보 없음',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
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
      ),
    );
  }

  void _updatePostStatus(String postId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('게시글 상태 변경'),
        content: Text('게시글 상태를 "${_getStatusText(newStatus)}"로 변경하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('posts').doc(postId).update({
                  'status': newStatus,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('게시글 상태가 변경되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('상태 변경 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
