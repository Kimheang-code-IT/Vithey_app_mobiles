import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/fixtures/notification_fixtures.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/notification_page_result.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';

class NotificationRepository extends GetxService {
  NotificationRepository(this._notificationService, this._flags);

  final NotificationService _notificationService;
  final FeatureFlags _flags;

  final unreadCount = 0.obs;
  final _items = <String, AppNotification>{};

  bool get useMockApi => _flags.useMockNotifications;

  @override
  void onInit() {
    super.onInit();
    if (useMockApi) {
      _seedMockData();
      _syncUnreadCount();
    }
  }

  Future<NotificationPageResult> fetchNotifications({
    NotificationFilter filter = NotificationFilter.all,
    int page = 1,
    int limit = 20,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      var list = _items.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      switch (filter) {
        case NotificationFilter.all:
          break;
        case NotificationFilter.read:
          list = list.where((n) => n.isRead).toList();
          break;
        case NotificationFilter.unread:
          list = list.where((n) => !n.isRead).toList();
          break;
      }
      final start = (page - 1) * limit;
      final pageItems = list.skip(start).take(limit).toList();
      return NotificationPageResult(
        items: pageItems,
        hasMore: start + pageItems.length < list.length,
        total: list.length,
        unreadTotal: _items.values.where((n) => !n.isRead).length,
      );
    }

    final result = await _notificationService.fetchNotifications(
      page: page,
      limit: limit,
      isRead: switch (filter) {
        NotificationFilter.all => null,
        NotificationFilter.read => true,
        NotificationFilter.unread => false,
      },
    );
    _cacheItems(result.items);
    if (result.unreadTotal != null) {
      unreadCount.value = result.unreadTotal!;
    } else if (page == 1) {
      await reconcileUnreadCount();
    }
    return result;
  }

  Future<void> markAsRead(String notificationId) async {
    final item = _items[notificationId];
    if (item != null && item.isRead) return;

    AppNotification? previous;
    if (item != null) {
      previous = item;
      _items[notificationId] = item.copyWith(isRead: true);
      _syncUnreadCount();
    }

    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return;
    }

    try {
      await _notificationService.markRead(notificationId);
      if (item == null) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
      }
    } catch (e) {
      if (previous != null) {
        _items[notificationId] = previous;
        _syncUnreadCount();
      }
      rethrow;
    }
  }

  Future<int> markAllAsRead() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      var updated = 0;
      for (final entry in _items.entries) {
        if (!entry.value.isRead) {
          _items[entry.key] = entry.value.copyWith(isRead: true);
          updated++;
        }
      }
      _syncUnreadCount();
      return updated;
    }

    final updated = await _notificationService.markAllRead();
    for (final entry in _items.entries) {
      if (!entry.value.isRead) {
        _items[entry.key] = entry.value.copyWith(isRead: true);
      }
    }
    unreadCount.value = 0;
    return updated;
  }

  Future<void> deleteNotification(String notificationId) async {
    final removed = _items.remove(notificationId);
    if (removed != null && !removed.isRead) {
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
    } else {
      _syncUnreadCount();
    }

    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return;
    }

    try {
      await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      if (removed != null) {
        _items[notificationId] = removed;
        _syncUnreadCount();
      }
      rethrow;
    }
  }

  AppNotification? getById(String id) => _items[id];

  void cacheNotification(AppNotification notification) =>
      _cacheItems([notification]);

  Future<void> reconcileUnreadCount() async {
    if (useMockApi) {
      _syncUnreadCount();
      return;
    }
    unreadCount.value = await _notificationService.fetchUnreadCount();
  }

  Future<void> onUserAuthenticated() async {
    await reconcileUnreadCount();
  }

  Future<void> onAppResumed() async {
    await reconcileUnreadCount();
  }

  void clearSession() {
    _items.clear();
    unreadCount.value = 0;
  }

  void _cacheItems(List<AppNotification> items) {
    for (final item in items) {
      if (item.id.isEmpty) continue;
      _items[item.id] = item;
    }
  }

  void _syncUnreadCount() {
    unreadCount.value = _items.values.where((n) => !n.isRead).length;
  }

  void _seedMockData() {
    for (final item in NotificationFixtures.buildNotifications()) {
      _items[item.id] = item;
    }
  }
}
