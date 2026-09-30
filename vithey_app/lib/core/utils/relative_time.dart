class RelativeTime {
  RelativeTime._();

  /// Relative date: `2 hours ago`, `3 days ago`, `1 month ago`, `2 years ago`.
  static String format(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) {
      return _plural(diff.inMinutes, 'minute', 'minutes');
    }
    if (diff.inHours < 24) {
      return _plural(diff.inHours, 'hour', 'hours');
    }
    if (diff.inDays < 30) {
      return _plural(diff.inDays, 'day', 'days');
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor().clamp(1, 11);
      return _plural(months, 'month', 'months');
    }
    final years = (diff.inDays / 365).floor().clamp(1, 999);
    return _plural(years, 'year', 'years');
  }

  static String _plural(int value, String singular, String plural) {
    return '$value ${value == 1 ? singular : plural} ago';
  }

  /// Chat list trailing time — e.g. `2m ago`, `Yesterday`.
  static String formatChatList(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (day == today) return '${diff.inHours}h ago';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Chat header subtitle when offline — e.g. `last seen 2 hours ago`.
  static String formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (day == today) return 'last seen today at $time';
    if (day == today.subtract(const Duration(days: 1))) {
      return 'last seen yesterday at $time';
    }
    return 'last seen ${format(dateTime)}';
  }
}
