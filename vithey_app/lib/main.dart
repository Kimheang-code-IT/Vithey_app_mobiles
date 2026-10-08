import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/app.dart';
import 'package:aub_connect_app/core/di/app_bindings.dart';
import 'package:aub_connect_app/core/localization/app_translations.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait only.
  // To allow landscape/rotation instead, change or remove this list.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeMode = await AppBindings.init();

  // Apply the saved language (English/Khmer) before the first frame.
  final savedLanguage = await Get.find<LocalStorageService>().readLanguage();
  AppTranslations.apply(savedLanguage);

  Get.changeThemeMode(themeMode);
  runApp(VitheyApp(themeMode: themeMode));
}
