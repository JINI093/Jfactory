import '../../entities/post_entity.dart';
import '../../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository _postRepository;

  GetPostsUseCase(this._postRepository);

  Future<List<PostEntity>> call(GetPostsParams params) async {
    try {
      return await _postRepository.getAllPosts(
        limit: params.limit,
        isPremium: params.isPremium,
        orderBy: params.orderBy,
        descending: params.descending,
      );
    } catch (e) {
      throw Exception('게시글 목록 조회 실패: ${e.toString()}');
    }
  }
}

class GetPostsParams {
  final int? limit;
  final bool? isPremium;
  final String? orderBy;
  final bool descending;

  GetPostsParams({
    this.limit,
    this.isPremium,
    this.orderBy,
    this.descending = true,
  });

  factory GetPostsParams.premium({int? limit}) {
    return GetPostsParams(
      limit: limit,
      isPremium: true,
      orderBy: 'createdAt',
      descending: true,
    );
  }

  factory GetPostsParams.general({int? limit}) {
    return GetPostsParams(
      limit: limit,
      isPremium: false,
      orderBy: 'createdAt',
      descending: true,
    );
  }

  factory GetPostsParams.popular({int? limit}) {
    return GetPostsParams(
      limit: limit,
      orderBy: 'viewCount',
      descending: true,
    );
  }
}