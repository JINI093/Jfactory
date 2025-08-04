import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<void> createPost(PostEntity post);
  Future<PostEntity?> getPost(String postId);
  Future<List<PostEntity>> getPostsByCompany(String companyId);
  Future<List<PostEntity>> getAllPosts({
    int? limit,
    bool? isPremium,
    String? orderBy,
    bool descending = true,
  });
  Future<void> updatePost(PostEntity post);
  Future<void> deletePost(String postId);
  Future<void> incrementPostViewCount(String postId);
}