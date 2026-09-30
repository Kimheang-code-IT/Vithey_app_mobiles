import 'package:aub_connect_app/data/models/post_author.dart';

class CommentModel {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.createdAt,
    this.parentCommentId,
    this.isPending = false,
    this.isFailed = false,
  });

  final String id;
  final String postId;
  final PostAuthor author;
  final String text;
  final DateTime createdAt;
  final String? parentCommentId;
  final bool isPending;
  final bool isFailed;

  bool get isReply => parentCommentId != null && parentCommentId!.isNotEmpty;

  bool isOwnedBy(String? userId) =>
      userId != null && userId.isNotEmpty && author.id == userId;

  CommentModel copyWith({
    String? id,
    String? text,
    String? parentCommentId,
    bool? isPending,
    bool? isFailed,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId,
      author: author,
      text: text ?? this.text,
      createdAt: createdAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['comment_id']?.toString() ?? json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      parentCommentId: json['parent_comment_id']?.toString(),
    );
  }
}
