import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/alerts/in_app_alert_host.dart';
import 'package:aub_connect_app/core/theme/app_theme.dart';
import 'package:aub_connect_app/core/theme/vithey_scroll_behavior.dart';
import 'package:aub_connect_app/core/utils/connectivity_wrapper.dart';
import 'package:aub_connect_app/routes/app_pages.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class VitheyApp extends StatelessWidget {
  const VitheyApp({super.key, required this.themeMode});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vithey App',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const VitheyScrollBehavior(),
      // shadcn_flutter widgets (text field context menu, etc.) look up
      // ShadcnLocalizations and crash if the delegate is not registered.
      localizationsDelegates: shad.ShadcnLocalizations.localizationsDelegates,
      supportedLocales: shad.ShadcnLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;

        // shadcn_flutter has its own theme system. We inject it here so all
        // shadcn_flutter components work anywhere in the app while we migrate
        // screen-by-screen.
        final shadColorScheme = (brightness == Brightness.dark
                ? shad.ColorSchemes.darkSlate
                : shad.ColorSchemes.lightSlate)
            .copyWith(
              primary: () => Theme.of(context).colorScheme.primary,
              primaryForeground: () => Colors.white,
              ring: () => Theme.of(context).colorScheme.primary,
            );

        return shad.Theme(
          data: shad.ThemeData(
            colorScheme: shadColorScheme,
            // ~20–24px corners on primary/destructive buttons (radiusXl).
            radius: 1.0,
          ),
          child: ConnectivityWrapper(
            child: InAppAlertHost(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
