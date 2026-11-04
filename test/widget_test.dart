import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/config/app_config.dart';
import 'package:rahhala_app/core/constants/app_constants.dart';

void main() {
  test('app constants and config expose expected metadata', () {
    expect(AppConstants.appName, isNotEmpty);
    expect(AppConfig.apiBaseUrl, startsWith('https://'));
    expect(AppConfig.chatBotBaseUrl, startsWith('https://'));
    expect(
      [
        AppConfig.developmentFlavor,
        AppConfig.stagingFlavor,
        AppConfig.productionFlavor,
      ],
      contains(AppConfig.flavor),
    );
  });
}
