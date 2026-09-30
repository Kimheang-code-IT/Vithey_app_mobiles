class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
