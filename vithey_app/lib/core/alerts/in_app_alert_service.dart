import 'dart:async';

import 'package:aub_connect_app/core/alerts/in_app_alert.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_call_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global heads-up alerts for chat messages and incoming calls.
class InAppAlertService extends GetxService {
  InAppAlertService(this._localStorage);

  final LocalStorageService _localStorage;

  final current = Rxn<InAppAlert>();
  Timer? _autoDismiss;
  VoidCallback? _onAcceptCall;
  VoidCallback? _onDeclineCall;

  static const _messageDuration = Duration(seconds: 5);
  static const _callDuration = Duration(seconds: 45);

  Future<bool> _allowsChatAlerts() async {
    if (!Get.isRegistered<SettingsRepository>()) return true;
    final prefs =
        await Get.find<SettingsRepository>().loadCachedNotificationPreferences();
    return prefs.allowsType(NotificationType.chatMessage);
  }

  Future<void> showChatMessage({
    required String conversationId,
    required String senderName,
    required String text,
    String? senderAvatarUrl,
    String? thumbnailUrl,
    String? participantId,
    DateTime? createdAt,
  }) async {
    if (!await _allowsChatAlerts()) return;
    if (await _localStorage.isConversationMuted(conversationId)) return;

    show(
      InAppAlert(
        id: 'msg-$conversationId-${createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
        kind: InAppAlertKind.message,
        title: senderName,
        body: text.trim().isEmpty ? 'Sent a message' : text.trim(),
        createdAt: createdAt ?? DateTime.now(),
        avatarUrl: senderAvatarUrl,
        thumbnailUrl: thumbnailUrl,
        conversationId: conversationId,
        participantId: participantId,
      ),
    );
  }

  Future<void> showIncomingCall({
    required ChatParticipant participant,
    required String conversationId,
    bool isVideo = false,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) async {
    if (!await _allowsChatAlerts()) return;
    if (await _localStorage.isConversationMuted(conversationId)) return;

    _onAcceptCall = onAccept;
    _onDeclineCall = onDecline;

    show(
      InAppAlert(
        id: 'call-$conversationId-${DateTime.now().millisecondsSinceEpoch}',
        kind: InAppAlertKind.incomingCall,
        title: participant.fullName,
        body: isVideo ? 'Incoming video call' : 'Incoming voice call',
        subtitle: 'mobile',
        createdAt: DateTime.now(),
        avatarUrl: participant.avatarUrl,
        conversationId: conversationId,
        participantId: participant.id,
        isVideoCall: isVideo,
      ),
      duration: _callDuration,
    );
  }

  void show(InAppAlert alert, {Duration? duration}) {
    _autoDismiss?.cancel();
    current.value = alert;
    final ttl = duration ??
        (alert.kind == InAppAlertKind.incomingCall
            ? _callDuration
            : _messageDuration);
    _autoDismiss = Timer(ttl, dismiss);
  }

  void dismiss() {
    _autoDismiss?.cancel();
    _autoDismiss = null;
    current.value = null;
    _onAcceptCall = null;
    _onDeclineCall = null;
  }

  void onMessageTap() {
    final alert = current.value;
    if (alert == null || alert.kind != InAppAlertKind.message) return;
    final conversationId = alert.conversationId;
    dismiss();
    if (conversationId == null || conversationId.isEmpty) return;
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: ChatDetailArgs(conversationId: conversationId),
    );
  }

  void onDeclineCall() {
    final custom = _onDeclineCall;
    dismiss();
    custom?.call();
  }

  void onAcceptCall() {
    final alert = current.value;
    final custom = _onAcceptCall;
    final participantId = alert?.participantId;
    final name = alert?.title ?? 'Caller';
    final avatar = alert?.avatarUrl;
    final isVideo = alert?.isVideoCall ?? false;
    dismiss();

    if (custom != null) {
      custom();
      return;
    }

    final ctx = Get.context;
    if (ctx == null || participantId == null) return;
    showChatCallSheet(
      context: ctx,
      participant: ChatParticipant(
        id: participantId,
        fullName: name,
        avatarUrl: avatar,
      ),
      isVideo: isVideo,
    );
  }

  @override
  void onClose() {
    _autoDismiss?.cancel();
    super.onClose();
  }
}
