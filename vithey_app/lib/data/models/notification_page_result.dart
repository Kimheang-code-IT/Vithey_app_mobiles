import 'package:aub_connect_app/data/models/app_notification_model.dart';

class NotificationPageResult {
  const NotificationPageResult({
    required this.items,
    required this.hasMore,
    this.total = 0,
    this.unreadTotal,
  });

  final List<AppNotification> items;
  final bool hasMore;
  final int total;
  final int? unreadTotal;
}
