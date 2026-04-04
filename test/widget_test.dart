import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/constants/app_constants.dart';

void main() {
  test('app constants expose expected non-empty metadata', () {
    expect(AppConstants.appName, isNotEmpty);
    expect(AppConstants.baseUrl, startsWith('https://'));
  });
}
