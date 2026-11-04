import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';

/// What the app must do after checking the remote app config.
enum AppUpdateRequirement { none, updateRequired, maintenance }

/// Result of [AppUpdateService.check].
class AppUpdateStatus extends Equatable {
  const AppUpdateStatus({
    required this.requirement,
    this.message,
    this.storeUrl,
  });

  static const AppUpdateStatus upToDate =
      AppUpdateStatus(requirement: AppUpdateRequirement.none);

  final AppUpdateRequirement requirement;

  /// Optional message from the config document (shown as-is).
  final String? message;

  /// Optional store link for the update button.
  final String? storeUrl;

  bool get blocksApp => requirement != AppUpdateRequirement.none;

  @override
  List<Object?> get props => [requirement, message, storeUrl];
}

/// Force-update and maintenance-mode check (DECISIONS D-15).
///
/// Fetches a small JSON document:
///
/// ```json
/// {
///   "minSupportedBuild": 3,
///   "latestBuild": 5,
///   "maintenance": false,
///   "message": "optional text",
///   "storeUrl": "https://play.google.com/store/apps/details?id=com.rahhala.app"
/// }
/// ```
///
/// The check **fails open**: if the URL is empty, the request fails, or the
/// document is malformed, the app continues normally. A broken config host
/// must never lock users out.
class AppUpdateService {
  AppUpdateService({
    required Dio dio,
    required String configUrl,
    required int Function() currentBuild,
  })  : _dio = dio,
        _configUrl = configUrl,
        _currentBuild = currentBuild;

  final Dio _dio;
  final String _configUrl;
  final int Function() _currentBuild;

  Future<AppUpdateStatus> check() async {
    if (_configUrl.isEmpty) return AppUpdateStatus.upToDate;

    try {
      final response = await _dio.get<dynamic>(
        _configUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      final data = response.data;
      if (data is! Map) return AppUpdateStatus.upToDate;
      return evaluate(Map<String, dynamic>.from(data), _currentBuild());
    } catch (e) {
      AppLogger.instance.w('AppUpdateService: config check skipped', error: e);
      return AppUpdateStatus.upToDate;
    }
  }

  /// Pure decision logic, separate so it can be unit-tested.
  static AppUpdateStatus evaluate(Map<String, dynamic> config, int build) {
    final message =
        config['message'] is String ? config['message'] as String : null;
    final storeUrl =
        config['storeUrl'] is String ? config['storeUrl'] as String : null;

    if (config['maintenance'] == true) {
      return AppUpdateStatus(
        requirement: AppUpdateRequirement.maintenance,
        message: message,
      );
    }

    final minBuild = config['minSupportedBuild'];
    if (minBuild is int && build > 0 && build < minBuild) {
      return AppUpdateStatus(
        requirement: AppUpdateRequirement.updateRequired,
        message: message,
        storeUrl: storeUrl,
      );
    }
    return AppUpdateStatus.upToDate;
  }
}
