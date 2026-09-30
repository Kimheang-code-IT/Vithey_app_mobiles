import 'package:aub_connect_app/core/alerts/in_app_alert.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Dark incoming-call heads-up banner with decline / accept actions.
class InAppIncomingCallBanner extends StatelessWidget {
  const InAppIncomingCallBanner({
    super.key,
    required this.alert,
    required this.onDecline,
    required this.onAccept,
  });

  final InAppAlert alert;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: alert.avatarUrl,
                name: alert.title,
                radius: 24,
                backgroundColor: const Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      alert.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.subtitle ??
                          (alert.isVideoCall ? 'Vithey Video' : 'mobile'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall
                          ?.copyWith(color: const Color(0xFFC7C7CC)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CallActionButton(
                color: const Color(0xFFFF3B30),
                icon: LucideIcons.phoneOff,
                tooltip: 'Decline',
                onPressed: onDecline,
              ),
              const SizedBox(width: 10),
              _CallActionButton(
                color: const Color(0xFF34C759),
                icon: alert.isVideoCall
                    ? LucideIcons.video
                    : LucideIcons.phone,
                tooltip: 'Accept',
                onPressed: onAccept,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: VitheyIcon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
