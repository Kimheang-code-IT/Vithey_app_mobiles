import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

class CommentRepository {
  CommentRepository(this._postRepository);

  final PostRepository _postRepository;

  static final mentionUsers = UserFixtures.mentionUsers();

  Future<List<CommentModel>> fetchComments({
    required String postId,
    int page = 1,
  }) {
    return _postRepository.fetchComments(postId, page: page);
  }

  Future<CommentModel> createComment({
    required String postId,
    required String text,
    required PostAuthor currentUser,
    String? parentCommentId,
  }) {
    return _postRepository.createComment(
      postId: postId,
      text: text,
      currentUser: currentUser,
      parentCommentId: parentCommentId,
    );
  }

  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String text,
  }) {
    return _postRepository.updateComment(
      postId: postId,
      commentId: commentId,
      text: text,
    );
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) {
    return _postRepository.deleteComment(
      postId: postId,
      commentId: commentId,
    );
  }

  List<PostAuthor> searchMentionUsers(String query) {
    final q = query.toLowerCase();
    if (q.isEmpty) return mentionUsers;
    return mentionUsers
        .where((u) => u.fullName.toLowerCase().contains(q))
        .toList();
  }
}
