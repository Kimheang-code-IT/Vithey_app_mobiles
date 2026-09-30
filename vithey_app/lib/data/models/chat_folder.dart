/// User-managed chat folder (Telegram-style).
class ChatFolder {
  const ChatFolder({
    required this.id,
    required this.name,
    this.conversationIds = const [],
  });

  final String id;
  final String name;
  final List<String> conversationIds;

  ChatFolder copyWith({
    String? name,
    List<String>? conversationIds,
  }) {
    return ChatFolder(
      id: id,
      name: name ?? this.name,
      conversationIds: conversationIds ?? this.conversationIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'conversationIds': conversationIds,
      };

  factory ChatFolder.fromJson(Map<String, dynamic> json) {
    final ids = (json['conversationIds'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    return ChatFolder(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      conversationIds: ids,
    );
  }
}

/// Built-in folder ids (not persisted as custom folders).
abstract final class ChatFolderIds {
  static const all = 'all';
  static const unread = 'unread';
}
