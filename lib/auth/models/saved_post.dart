enum PostType { post, video, recipe, job, blog }

class SavedPost {
  final String postId;
  final PostType type;

  SavedPost({
    required this.postId,
    required this.type,
  });

  factory SavedPost.fromMap(Map<String, dynamic> data) {
    return SavedPost(
      postId: data['postId'] ?? '',
      type: _getPostTypeFromString(data['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'type': _getStringFromPostType(type),
    };
  }

  static PostType _getPostTypeFromString(String? typeString) {
    switch (typeString) {
      case 'post':
        return PostType.post;
      case 'video':
        return PostType.video;
      case 'recipe':
        return PostType.recipe;
      case 'job':
        return PostType.job;
      case 'blog':
        return PostType.blog;
      default:
        return PostType.post;
    }
  }

  static String _getStringFromPostType(PostType type) {
    switch (type) {
      case PostType.post:
        return 'post';
      case PostType.video:
        return 'video';
      case PostType.recipe:
        return 'recipe';
      case PostType.job:
        return 'job';
      case PostType.blog:
        return 'blog';
    }
  }
}
