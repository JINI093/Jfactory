import '../../entities/post_entity.dart';
import '../../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository _postRepository;

  CreatePostUseCase(this._postRepository);

  Future<void> call(CreatePostParams params) async {
    try {
      final post = PostEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: params.companyId,
        title: params.title,
        content: params.content,
        images: params.images,
        status: PostStatus.draft,
        createdAt: DateTime.now(),
        viewCount: 0,
        tags: params.tags,
        isPremium: params.isPremium,
        premiumExpiryDate: params.isPremium ? params.premiumExpiryDate : null,
      );

      await _postRepository.createPost(post);
    } catch (e) {
      throw Exception('게시글 생성 실패: ${e.toString()}');
    }
  }
}

class CreatePostParams {
  final String companyId;
  final String title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final bool isPremium;
  final DateTime? premiumExpiryDate;

  CreatePostParams({
    required this.companyId,
    required this.title,
    required this.content,
    this.images = const [],
    this.tags = const [],
    this.isPremium = false,
    this.premiumExpiryDate,
  });
}