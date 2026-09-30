class ChatSharedFile {
  const ChatSharedFile({
    required this.name,
    required this.sizeLabel,
    required this.sharedAt,
    this.downloadUrl,
  });

  final String name;
  final String sizeLabel;
  final DateTime sharedAt;
  final String? downloadUrl;
}

class ChatSharedLink {
  const ChatSharedLink({
    required this.url,
    required this.sharedAt,
    this.title,
    this.description,
  });

  final String url;
  final DateTime sharedAt;
  final String? title;
  final String? description;

  String get monthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[sharedAt.month - 1];
  }
}

class ChatSharedContent {
  const ChatSharedContent({
    this.imageUrls = const [],
    this.videoUrls = const [],
    this.files = const [],
    this.links = const [],
  });

  final List<String> imageUrls;
  final List<String> videoUrls;
  final List<ChatSharedFile> files;
  final List<ChatSharedLink> links;
}
