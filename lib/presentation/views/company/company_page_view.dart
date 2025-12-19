import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/company_viewmodel.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../data/models/post_model.dart';

class CompanyPageView extends StatefulWidget {
  final String companyId;

  const CompanyPageView({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyPageView> createState() => _CompanyPageViewState();
}

class _CompanyPageViewState extends State<CompanyPageView> {
  List<PostEntity> _posts = [];
  bool _isLoadingPosts = false;
  Map<String, dynamic>? _companyData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyViewModel>().loadCompany(widget.companyId);
      _loadPosts();
      _loadCompanyData();
    });
  }

  Future<void> _loadCompanyData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .get();
      
      if (doc.exists) {
        setState(() {
          _companyData = doc.data();
        });
      }
    } catch (e) {
      debugPrint('Error loading company data: $e');
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      QuerySnapshot snapshot;
      try {
        snapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('companyId', isEqualTo: widget.companyId)
            .where('status', isEqualTo: 'published')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // 인덱스 오류 시 orderBy 없이 조회
        snapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('companyId', isEqualTo: widget.companyId)
            .where('status', isEqualTo: 'published')
            .get();
      }

      final posts = snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return PostModel.fromJson(data).toEntity();
        } catch (e) {
          return null;
        }
      }).where((post) => post != null).cast<PostEntity>().toList();

      // 클라이언트에서 정렬
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _posts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<CompanyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadCompany(widget.companyId),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final company = viewModel.selectedCompany;
          if (company == null) {
            return const Center(child: Text('기업 정보를 찾을 수 없습니다.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyHeader(company),
                _buildCompanyImage(company),
                _buildMainCategories(company),
                _buildCategoryTabs(),
                _buildSection('특징', company),
                _buildSection('오시는 길', company),
                _buildMap(company),
                _buildHistory(company),
                _buildProducts(company),
                SizedBox(height: 80.h),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/main');
          }
        },
      ),
      title: Image.asset(
        'assets/icons/logo2.png',
        height: 32.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            '제작소',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompanyHeader(CompanyEntity company) {
    // 로고 URL 확인 (logo 필드 또는 photos의 첫 번째 이미지)
    final logoUrl = company.logo ?? (company.photos.isNotEmpty ? company.photos.first : null);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFDFEBFF),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            // 로고 이미지
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // 네트워크 이미지 로드 실패 시 기본 로고 표시
                          return Image.asset(
                            'assets/icons/logo.png',
                            width: 48.w,
                            height: 48.h,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/icons/logo.png',
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // 기업명 (가로 길이 꽉 차게)
            Expanded(
              child: Text(
                company.companyName.isNotEmpty ? company.companyName : '기업명 없음',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyImage(CompanyEntity company) {
    // 실제 카테고리 데이터 수집
    final List<String> categories = [];
    if (company.category.isNotEmpty) {
      categories.add(company.category);
    }
    if (company.subcategory.isNotEmpty) {
      categories.add(company.subcategory);
    }
    if (company.subSubcategory != null && company.subSubcategory!.isNotEmpty) {
      categories.add(company.subSubcategory!);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: company.photos.isNotEmpty
                  ? Image.network(
                      company.photos.first,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.business,
                            size: 40.sp,
                            color: Colors.grey[500],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.business,
                        size: 40.sp,
                        color: Colors.grey[500],
                      ),
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: categories.isEmpty
                ? Text(
                    '카테고리 정보 없음',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories
                        .map((category) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: _buildCategoryTag(category),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMainCategories(CompanyEntity company) {
    // Firestore에서 clients 데이터 가져오기
    final clients = _companyData?['clients'] as List<dynamic>? ?? [];
    final clientNames = clients
        .map((client) => client['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    if (clientNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주요 거래처',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: clientNames
                .take(6) // 최대 6개만 표시
                .map((name) => SizedBox(
                      width: (MediaQuery.of(context).size.width - 48.w - 24.w) / 3,
                      child: _buildPartnerCard(name),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container();
  }

  Widget _buildSection(String title, CompanyEntity company) {
    String? content;
    
    if (title == '특징') {
      content = _companyData?['features']?.toString();
    } else if (title == '인사말') {
      content = company.greeting;
    }

    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          if (title == '특징') ...[
            // 특징은 줄바꿈으로 구분된 항목들로 표시
            ...content.split('\n')
                .where((line) => line.trim().isNotEmpty)
                .map((line) => _buildFeatureItem('• ${line.trim()}')),
          ] else if (title == '인사말') ...[
            Text(
              content,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            if (_companyData?['ceoName'] != null) ...[
              SizedBox(height: 16.h),
              Text(
                '${_companyData!['ceoName']}  대표이사',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMap(CompanyEntity company) {
    final address = company.address.isNotEmpty 
        ? company.address 
        : (_companyData?['address']?.toString() ?? '');
    final detailAddress = company.detailAddress.isNotEmpty
        ? company.detailAddress
        : (_companyData?['detailAddress']?.toString() ?? '');
    
    final fullAddress = detailAddress.isNotEmpty 
        ? '$address $detailAddress' 
        : address;

    if (fullAddress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주소   $fullAddress',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                'assets/images/map_placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 40.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildHistory(CompanyEntity company) {
    final history = _companyData?['history'] as List<dynamic>? ?? [];
    
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연혁',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          ...history.map((item) {
            final year = item['year']?.toString() ?? '';
            final content = item['content']?.toString() ?? '';
            if (year.isEmpty && content.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (year.isNotEmpty)
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        year,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (year.isNotEmpty) SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProducts(CompanyEntity company) {
    // 프리미엄 게시글과 일반 게시글 분리
    final premiumPosts = _posts.where((post) => post.isPremium).toList();
    final normalPosts = _posts.where((post) => !post.isPremium).toList();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이 기업 게시글',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (premiumPosts.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildProductSection('프리미엄 게시글', premiumPosts),
          ],
          if (normalPosts.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildProductSection('일반게시글', normalPosts),
          ],
          if (_posts.isEmpty && !_isLoadingPosts)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Text(
                '등록된 게시글이 없습니다.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductSection(String title, List<PostEntity> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(posts[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(PostEntity post) {
    final imageUrl = post.images.isNotEmpty ? post.images.first : null;
    final categoryText = (post.subcategory?.isNotEmpty == true) 
        ? post.subcategory! 
        : ((post.category?.isNotEmpty == true) ? post.category! : '카테고리 없음');

    return GestureDetector(
      onTap: () {
        context.push('/post/${post.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: post.isPremium ? const Color(0xFFFF9800) : Colors.grey[300]!,
            width: post.isPremium ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image,
                                    size: 30.sp,
                                    color: Colors.grey[500],
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image,
                                size: 30.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                    ),
                  ),
                  if (post.isPremium)
                    Positioned(
                      top: 4.h,
                      left: 4.w,
                      child: Icon(
                        Icons.verified,
                        color: const Color(0xFFFF9800),
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (post.equipmentName?.isNotEmpty == true) ? post.equipmentName! : (post.title.isNotEmpty ? post.title : '게시글 제목 없음'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    categoryText,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Consumer<CompanyViewModel>(
      builder: (context, viewModel, child) {
        final company = viewModel.selectedCompany;
        if (company == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: company.phone.isNotEmpty
                      ? () async {
                          final uri = Uri.parse('tel:${company.phone.replaceAll('-', '').replaceAll(' ', '')}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E3A5F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    '전화걸기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: company.website != null && company.website!.isNotEmpty
                      ? () async {
                          String url = company.website!;
                          if (!url.startsWith('http://') && !url.startsWith('https://')) {
                            url = 'https://$url';
                          }
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    '회사홈페이지',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}