import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/company_viewmodel.dart';
import '../../../domain/entities/company_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../data/models/post_model.dart';

class CompanyDetailView extends StatefulWidget {
  final String companyId;

  const CompanyDetailView({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
  List<PostEntity> _posts = [];
  bool _isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyViewModel>().loadCompany(widget.companyId);
      _loadPosts();
    });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('기업 소개'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<CompanyViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.selectedCompany == null) return const SizedBox();
              
              return IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => viewModel.toggleFavorite(viewModel.selectedCompany!.id),
              );
            },
          ),
        ],
      ),
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final company = viewModel.selectedCompany;
          if (company == null) {
            return const Center(child: Text('Company not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopLogoBand(),
                _buildHeroImage(company),
                _buildHeaderInfo(company),
                const SizedBox(height: 8),
                _buildChipsSection(company),
                const SizedBox(height: 8),
                _buildPartnersSection(),
                const SizedBox(height: 8),
                _buildFeaturesSection(),
                const SizedBox(height: 8),
                _buildMapSection(company),
                const SizedBox(height: 8),
                _buildAboutSection(company),
                const SizedBox(height: 8),
                _buildCompanyPostsSection(company),
                const SizedBox(height: 8),
                _buildContactSection(company),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopLogoBand() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Image.asset(
          'assets/icons/logo2.png',
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeroImage(CompanyEntity company) {
    // 이미지 URL 우선순위: photos[0] > logo
    String? imageUrl;
    if (company.photos.isNotEmpty) {
      imageUrl = company.photos.first.trim();
      if (imageUrl.isEmpty) imageUrl = null;
    }
    if (imageUrl == null && company.logo != null && company.logo!.trim().isNotEmpty) {
      imageUrl = company.logo!.trim();
    }

    // 디버깅용 로그
    debugPrint('기업 이미지 로딩 시도:');
    debugPrint('  - photos.length: ${company.photos.length}');
    debugPrint('  - photos[0]: ${company.photos.isNotEmpty ? company.photos.first : "없음"}');
    debugPrint('  - logo: ${company.logo ?? "없음"}');
    debugPrint('  - 최종 imageUrl: $imageUrl');

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('이미지 로딩 실패: $imageUrl');
                debugPrint('에러: $error');
                debugPrint('스택 트레이스: $stackTrace');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        '이미지를 불러올 수 없습니다',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        imageUrl != null && imageUrl.length > 50 ? '${imageUrl.substring(0, 50)}...' : (imageUrl ?? ''),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    '기업 이미지 없음',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderInfo(CompanyEntity company) {
    final categoryLine = _composeCategoryLine(company);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company.companyName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.category, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  categoryLine,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  company.address,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipsSection(CompanyEntity company) {
    final List<String> chips = [];
    if (company.category.isNotEmpty) chips.add(company.category);
    if (company.subcategory.isNotEmpty) chips.add(company.subcategory);
    if ((company.subSubcategory ?? '').isNotEmpty) chips.add(company.subSubcategory!);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips
            .map((text) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                  ),
                  child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPartnersSection() {
    final partners = ['네이버 기업', '카톡기업', '쿠팡'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주요거래처',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: partners
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(p, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = ['건설 산업 장비 보유', '시설 완비', '협력업체 경험 다수 보유'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '특징',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 14, color: Colors.black87))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMapSection(CompanyEntity company) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오시는 길',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('주소  ', style: TextStyle(fontSize: 14, color: Colors.black87)),
              Expanded(
                child: Text(
                  company.address,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.map, size: 40, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(CompanyEntity company) {
    final hasGreeting = (company.greeting ?? '').trim().isNotEmpty;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기업 소개',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            hasGreeting ? company.greeting!.trim() : '등록된 소개 문구가 없습니다.',
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyPostsSection(CompanyEntity company) {
    final premiumPosts = _posts.where((p) => p.isPremium).toList();
    final generalPosts = _posts.where((p) => !p.isPremium).toList();

    if (_isLoadingPosts) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 기업 게시글',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (premiumPosts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('프리미엄 게시글', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildPostGrid(posts: premiumPosts),
          ],
          if (generalPosts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('일반게시글', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildPostGrid(posts: generalPosts),
          ],
        ],
      ),
    );
  }

  Widget _buildPostGrid({required List<PostEntity> posts}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(post: posts[index]);
      },
    );
  }

  Widget _buildPostCard({required PostEntity post}) {
    final imageUrl = post.images.isNotEmpty ? post.images.first : null;
    final categoryText = post.subcategory ?? post.category ?? '카테고리 없음';

    return GestureDetector(
      onTap: () {
        context.push('/post/${post.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 30, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 30, color: Colors.grey),
                          ),
                  ),
                  if (post.isPremium)
                    const Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(Icons.verified, color: Color(0xFFFF9800), size: 18),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.red, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryText,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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

  Widget _buildContactSection(CompanyEntity company) {
    final hasWebsite = (company.website ?? '').trim().isNotEmpty;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _launchPhone(company.phone),
              icon: const Icon(Icons.call, color: Color(0xFF1E3A5F)),
              label: const Text('전화걸기'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E3A5F)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: hasWebsite ? () => _launchWebsite(company.website!.trim()) : null,
              icon: const Icon(Icons.public, color: Colors.white),
              label: const Text('회사홈페이지'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _composeCategoryLine(CompanyEntity company) {
    final parts = <String>[];
    if (company.category.isNotEmpty) parts.add(company.category);
    if (company.subcategory.isNotEmpty) parts.add(company.subcategory);
    if ((company.subSubcategory ?? '').isNotEmpty) parts.add(company.subSubcategory!);
    return parts.join(' > ');
  }

  Future<void> _launchPhone(String rawPhone) async {
    try {
      final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.isEmpty) return;
      final uri = Uri(scheme: 'tel', path: cleaned);
      if (!await launchUrl(uri)) {
        throw Exception('전화 앱을 열 수 없습니다.');
      }
    } catch (_) {}
  }

  Future<void> _launchWebsite(String rawUrl) async {
    try {
      String url = rawUrl;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('브라우저를 열 수 없습니다.');
      }
    } catch (_) {}
  }

  // removed unused _buildEquipmentCard

  // removed unused _buildSpecRow
}