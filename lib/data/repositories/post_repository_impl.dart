import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final FirestoreDataSource _dataSource;

  PostRepositoryImpl(this._dataSource);

  @override
  Future<void> createPost(PostEntity post) async {
    try {
      final postModel = PostModel.fromEntity(post);
      await _dataSource.createPost(postModel);
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }

  @override
  Future<PostEntity?> getPost(String postId) async {
    try {
      final postModel = await _dataSource.getPost(postId);
      return postModel?.toEntity();
    } catch (e) {
      throw Exception('게시글 조회 실패: $e');
    }
  }

  @override
  Future<List<PostEntity>> getPostsByCompany(String companyId) async {
    try {
      final postModels = await _dataSource.getPostsByCompany(companyId);
      return postModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('회사 게시글 조회 실패: $e');
    }
  }

  @override
  Future<List<PostEntity>> getAllPosts({
    int? limit,
    bool? isPremium,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final postModels = await _dataSource.getAllPosts(
        limit: limit,
        isPremium: isPremium,
        orderBy: orderBy,
        descending: descending,
      );
      return postModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('전체 게시글 조회 실패: $e');
    }
  }

  @override
  Future<void> updatePost(PostEntity post) async {
    try {
      final postModel = PostModel.fromEntity(post);
      await _dataSource.updatePost(postModel);
    } catch (e) {
      throw Exception('게시글 업데이트 실패: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _dataSource.deletePost(postId);
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  @override
  Future<void> incrementPostViewCount(String postId) async {
    try {
      await _dataSource.incrementPostViewCount(postId);
    } catch (e) {
      throw Exception('게시글 조회수 증가 실패: $e');
    }
  }

  @override
  Stream<List<PostEntity>> streamUserPosts(String userId) {
    try {
      print('🔍 StreamUserPosts called for userId: $userId');
      return _dataSource.streamUserPosts(userId).map((postModels) {
        print('📊 Posts snapshot received: ${postModels.length} documents');
        return postModels.map((model) => model.toEntity()).toList();
      });
    } catch (e) {
      print('❌ StreamUserPosts error: $e');
      rethrow;
    }
  }
}