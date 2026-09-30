import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';

class SearchRecentStore {
  static const _itemsKey = 'search_recent_items_v2';
  static const _legacyUsersKey = 'search_recent_users';
  static const maxUnpinnedItems = 20;

  Future<List<SearchRecentItem>> getRecentItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        return _sort(list
            .map((e) => SearchRecentItem.fromJson(e as Map<String, dynamic>))
            .toList());
      } catch (_) {
        return [];
      }
    }
    return _migrateLegacyUsers(prefs);
  }

  Future<List<SearchRecentItem>> _migrateLegacyUsers(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_legacyUsersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final migrated = list
          .map((e) => SearchRecentItem.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveRecentItems(migrated);
      await prefs.remove(_legacyUsersKey);
      return _sort(migrated);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentItems(List<SearchRecentItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(_trimAndSort(items).map((item) => item.toJson()).toList());
    await prefs.setString(_itemsKey, encoded);
  }

  Future<void> addRecentUser(SearchRecentItem user) async {
    final current = await getRecentItems();
    final existing = current.firstWhereOrNull((item) => item.id == user.id);
    current.removeWhere((item) => item.id == user.id);
    current.add(
      SearchRecentItem(
        id: user.id,
        type: SearchRecentType.user,
        title: user.title,
        accessedAt: DateTime.now(),
        userId: user.userId,
        avatarUrl: user.avatarUrl,
        followerCount: user.followerCount,
        isPinned: existing?.isPinned ?? user.isPinned,
        pinnedAt: existing?.pinnedAt ?? user.pinnedAt,
      ),
    );
    await saveRecentItems(current);
  }

  Future<void> addRecentFromResult(UserSearchResult result) {
    return addRecentUser(
      SearchRecentItem(
        id: 'user:${result.userId}',
        type: SearchRecentType.user,
        title: result.fullName,
        userId: result.userId,
        avatarUrl: result.avatarUrl,
        followerCount: result.followerCount,
        accessedAt: DateTime.now(),
      ),
    );
  }

  Future<void> addRecentQuery(String query) async {
    final title = query.trim();
    if (title.isEmpty) return;
    final id = 'query:${title.toLowerCase()}';
    final current = await getRecentItems();
    final existing = current.firstWhereOrNull((item) => item.id == id);
    current.removeWhere((item) => item.id == id);
    current.add(
      SearchRecentItem(
        id: id,
        type: SearchRecentType.query,
        title: title,
        accessedAt: DateTime.now(),
        isPinned: existing?.isPinned ?? false,
        pinnedAt: existing?.pinnedAt,
      ),
    );
    await saveRecentItems(current);
  }

  Future<void> setPinned(String itemId, bool pinned) async {
    final current = await getRecentItems();
    final index = current.indexWhere((item) => item.id == itemId);
    if (index < 0) return;
    current[index] = current[index].copyWith(
      isPinned: pinned,
      pinnedAt: pinned ? DateTime.now() : null,
    );
    await saveRecentItems(current);
  }

  Future<void> removeRecent(String itemId) async {
    final current = await getRecentItems();
    current.removeWhere((item) => item.id == itemId);
    await saveRecentItems(current);
  }

  Future<void> clearAll({bool includePinned = true}) async {
    final prefs = await SharedPreferences.getInstance();
    if (includePinned) {
      await prefs.remove(_itemsKey);
      await prefs.remove(_legacyUsersKey);
      return;
    }
    final pinned =
        (await getRecentItems()).where((item) => item.isPinned).toList();
    await saveRecentItems(pinned);
  }

  Future<void> seedDefaultsIfEmpty(
    List<SearchRecentItem> defaults,
  ) async {
    final current = await getRecentItems();
    if (current.isNotEmpty) return;
    await saveRecentItems(defaults);
  }

  List<SearchRecentItem> _trimAndSort(List<SearchRecentItem> items) {
    final pinned = items.where((item) => item.isPinned).toList();
    final unpinned = items.where((item) => !item.isPinned).toList()
      ..sort((a, b) => b.accessedAt.compareTo(a.accessedAt));
    return _sort([...pinned, ...unpinned.take(maxUnpinnedItems)]);
  }

  List<SearchRecentItem> _sort(List<SearchRecentItem> items) {
    items.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      if (a.isPinned) {
        return (a.pinnedAt ?? a.accessedAt)
            .compareTo(b.pinnedAt ?? b.accessedAt);
      }
      return b.accessedAt.compareTo(a.accessedAt);
    });
    return items;
  }
}

extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E value) test) {
    for (final value in this) {
      if (test(value)) return value;
    }
    return null;
  }
}
