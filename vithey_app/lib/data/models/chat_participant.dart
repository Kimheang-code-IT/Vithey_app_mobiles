class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    this.location,
    this.phone,
    this.isOnline = false,
    this.lastSeenAt,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? phone;
  final bool isOnline;

  /// When [isOnline] is false, shown as "last seen …" in the chat header.
  final DateTime? lastSeenAt;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    final rawLastSeen = json['last_seen_at'] ?? json['lastSeenAt'];
    DateTime? lastSeenAt;
    if (rawLastSeen is String) {
      lastSeenAt = DateTime.tryParse(rawLastSeen);
    } else if (rawLastSeen is DateTime) {
      lastSeenAt = rawLastSeen;
    }

    return ChatParticipant(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeenAt: lastSeenAt,
    );
  }
}
