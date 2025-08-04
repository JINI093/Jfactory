import '../../entities/post_entity.dart';
import '../../repositories/post_repository.dart';

class GetPostByIdUseCase {
  final PostRepository _postRepository;

  GetPostByIdUseCase(this._postRepository);

  Future<PostEntity?> call(String postId) async {
    try {
      // Increment view count when getting post
      await _postRepository.incrementPostViewCount(postId);
      return await _postRepository.getPost(postId);
    } catch (e) {
      throw Exception('게시글 조회 실패: ${e.toString()}');
    }
  }
}