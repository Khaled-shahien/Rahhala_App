import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahhala_app/core/update/app_update_service.dart';

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AppUpdateService.evaluate', () {
    test('requires an update below the minimum supported build', () {
      final status = AppUpdateService.evaluate(
        {'minSupportedBuild': 5, 'storeUrl': 'https://store/app'},
        4,
      );
      expect(status.requirement, AppUpdateRequirement.updateRequired);
      expect(status.storeUrl, 'https://store/app');
      expect(status.blocksApp, isTrue);
    });

    test('lets supported builds through', () {
      expect(
        AppUpdateService.evaluate({'minSupportedBuild': 5}, 5),
        AppUpdateStatus.upToDate,
      );
    });

    test('maintenance wins over everything else', () {
      final status = AppUpdateService.evaluate(
        {'maintenance': true, 'message': 'Back at 6pm', 'minSupportedBuild': 1},
        10,
      );
      expect(status.requirement, AppUpdateRequirement.maintenance);
      expect(status.message, 'Back at 6pm');
    });

    test('ignores malformed fields', () {
      expect(
        AppUpdateService.evaluate(
          {'minSupportedBuild': '9', 'maintenance': 'yes'},
          1,
        ),
        AppUpdateStatus.upToDate,
      );
    });

    test('never blocks when the current build is unknown', () {
      expect(
        AppUpdateService.evaluate({'minSupportedBuild': 99}, 0),
        AppUpdateStatus.upToDate,
      );
    });
  });

  group('AppUpdateService.check', () {
    test('does nothing when no URL is configured', () async {
      final adapter = _JsonAdapter('{}');
      final service = AppUpdateService(
        dio: Dio()..httpClientAdapter = adapter,
        configUrl: '',
        currentBuild: () => 1,
      );

      expect(await service.check(), AppUpdateStatus.upToDate);
      expect(adapter.calls, 0);
    });

    test('reads the remote document', () async {
      final service = AppUpdateService(
        dio: Dio()
          ..httpClientAdapter = _JsonAdapter('{"minSupportedBuild": 3}'),
        configUrl: 'https://config.example.com/app.json',
        currentBuild: () => 2,
      );

      expect((await service.check()).requirement,
          AppUpdateRequirement.updateRequired);
    });

    test('fails open when the config host errors', () async {
      final service = AppUpdateService(
        dio: Dio()
          ..httpClientAdapter = _JsonAdapter('oops', statusCode: 500),
        configUrl: 'https://config.example.com/app.json',
        currentBuild: () => 2,
      );

      expect(await service.check(), AppUpdateStatus.upToDate);
    });
  });
}
