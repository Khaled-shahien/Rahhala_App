import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/repositories/trip_options_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/trip_option.dart';

class RemoteTripOptionsRepository implements TripOptionsRepository {
  RemoteTripOptionsRepository({
    required ApiConsumer api,
    required TripOptionsRepository fallback,
  })  : _api = api,
        _fallback = fallback;

  final ApiConsumer _api;
  final TripOptionsRepository _fallback;

  @override
  Future<TripOptionsConfig> getTripOptions() async {
    try {
      final response = await _api.get(EndPoints.tripOptions);
      if (response is Map<String, dynamic>) {
        return TripOptionsConfig.fromJson(response);
      }
    } catch (e, stackTrace) {
      AppLogger.instance.w(
        'RemoteTripOptionsRepository: falling back to bundled options',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return _fallback.getTripOptions();
  }
}
