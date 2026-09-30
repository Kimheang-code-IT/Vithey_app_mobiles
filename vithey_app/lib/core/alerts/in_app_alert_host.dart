import 'package:aub_connect_app/core/alerts/in_app_alert.dart';
import 'package:aub_connect_app/core/alerts/in_app_alert_service.dart';
import 'package:aub_connect_app/core/alerts/in_app_incoming_call_banner.dart';
import 'package:aub_connect_app/core/alerts/in_app_message_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Overlays heads-up chat alerts above the active route.
class InAppAlertHost extends StatelessWidget {
  const InAppAlertHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InAppAlertService>()) {
      return child;
    }

    final alerts = Get.find<InAppAlertService>();

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Obx(() {
              final alert = alerts.current.value;
              if (alert == null) return const SizedBox.shrink();

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offset,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(alert.id),
                  child: alert.kind == InAppAlertKind.incomingCall
                      ? InAppIncomingCallBanner(
                          alert: alert,
                          onDecline: alerts.onDeclineCall,
                          onAccept: alerts.onAcceptCall,
                        )
                      : InAppMessageBanner(
                          alert: alert,
                          onTap: alerts.onMessageTap,
                          onDismiss: alerts.dismiss,
                        ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
