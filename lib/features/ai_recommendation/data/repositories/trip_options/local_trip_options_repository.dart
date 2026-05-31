import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/repositories/trip_options_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/trip_option.dart';

class LocalTripOptionsRepository implements TripOptionsRepository {
  const LocalTripOptionsRepository({
    this.assetPath = 'assets/config/trip_options.json',
  });

  final String assetPath;

  @override
  Future<TripOptionsConfig> getTripOptions() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return TripOptionsConfig.fromJson(json);
  }
}
