import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('init tolerates a missing .env and applies safe development defaults', () async {
    await AppConfig.init(envFileName: 'definitely-missing.env');

    expect(AppConfig.isInitialized, isTrue);
    expect(AppConfig.instance.environment, AppEnvironment.development);
    expect(AppConfig.instance.apiBaseUrl, contains('/api/v1'));
    expect(AppConfig.instance.wsBaseUrl, isNotEmpty);
    expect(AppConfig.instance.connectTimeout.inSeconds, greaterThan(0));
    expect(AppConfig.instance.receiveTimeout.inSeconds, greaterThan(0));
  });
}
