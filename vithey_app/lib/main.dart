import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/app.dart';
import 'package:aub_connect_app/core/di/app_bindings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeMode = await AppBindings.init();
  Get.changeThemeMode(themeMode);
  runApp(VitheyApp(themeMode: themeMode));
}
