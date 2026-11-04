import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rahhala_app/core/constants/app_constants.dart';
import 'package:rahhala_app/core/crash/crash_reporting_service.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';

class AppErrorReporter {
  AppErrorReporter._();

  static CrashReportingService _crashReportingService =
      const NoopCrashReportingService();

  static void configure(CrashReportingService service) {
    _crashReportingService = service;
  }

  static void record(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    AppLogger.instance.e(message, error: error, stackTrace: stackTrace);

    if (!kReleaseMode || !AppConstants.enableCrashReporting || error == null) {
      return;
    }

    unawaited(
      _crashReportingService.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: fatal,
      ),
    );
  }
}
