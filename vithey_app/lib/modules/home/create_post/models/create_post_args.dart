import 'package:aub_connect_app/data/models/feed_post.dart';

class CreatePostArgs {
  const CreatePostArgs({
    this.initialType,
    this.editingPost,
  });

  final PostType? initialType;
  final FeedPost? editingPost;

  bool get isEditing => editingPost != null;

  static CreatePostArgs from(dynamic arguments) {
    if (arguments is CreatePostArgs) return arguments;
    if (arguments is PostType) {
      return CreatePostArgs(initialType: arguments);
    }
    return const CreatePostArgs();
  }
}
