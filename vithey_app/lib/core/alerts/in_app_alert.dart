import 'package:flutter/foundation.dart';

enum InAppAlertKind { message, incomingCall }

/// Payload for a transient on-screen heads-up alert.
@immutable
class InAppAlert {
  const InAppAlert({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.avatarUrl,
    this.thumbnailUrl,
    this.conversationId,
    this.participantId,
    this.isVideoCall = false,
    this.subtitle,
  });

  final String id;
  final InAppAlertKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? thumbnailUrl;
  final String? conversationId;
  final String? participantId;
  final bool isVideoCall;
  /// Secondary line under the title (e.g. "mobile" on call banners).
  final String? subtitle;

  InAppAlert copyWith({
    String? title,
    String? body,
    String? subtitle,
  }) {
    return InAppAlert(
      id: id,
      kind: kind,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      avatarUrl: avatarUrl,
      thumbnailUrl: thumbnailUrl,
      conversationId: conversationId,
      participantId: participantId,
      isVideoCall: isVideoCall,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
