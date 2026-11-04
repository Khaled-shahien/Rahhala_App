import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/navigation_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_polling_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_update.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_route_helpers.dart';

abstract class TripNavigationState extends Equatable {
  const TripNavigationState();

  @override
  List<Object?> get props => [];
}

class TripNavigationIdle extends TripNavigationState {
  const TripNavigationIdle();
}

class TripNavigationLoading extends TripNavigationState {
  const TripNavigationLoading();
}

class TripNavigationNavigating extends TripNavigationState {
  const TripNavigationNavigating({
    required this.routeData,
    required this.currentLocation,
    this.latestUpdate,
  });

  final TripRouteResponseData routeData;
  final LatLng currentLocation;
  final RouteUpdate? latestUpdate;

  @override
  List<Object?> get props => [routeData, currentLocation, latestUpdate];
}

class TripNavigationError extends TripNavigationState {
  const TripNavigationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class TripNavigationCubit extends Cubit<TripNavigationState> {
  TripNavigationCubit({
    required NavigationService navigationService,
    required RoutePollingService routePollingService,
  })  : _navigationService = navigationService,
        _routePollingService = routePollingService,
        super(const TripNavigationIdle());

  final NavigationService _navigationService;
  final RoutePollingService _routePollingService;

  StreamSubscription<RouteUpdate>? _routeSubscription;
  TripRouteResponseData? _activeRoute;

  Future<void> startNavigation(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      emit(TripNavigationError(
        AppMessages.current.tripNavNoDestination,
      ));
      return;
    }

    emit(const TripNavigationLoading());

    try {
      final currentLocation = await _navigationService.startNavigation();
      if (currentLocation == null) {
        emit(TripNavigationError(
          AppMessages.current.tripNavLocationUnavailable,
        ));
        return;
      }

      final routeData = await _navigationService.requestRoute(
        from: currentLocation,
        to: waypoints.first,
      );
      if (routeData == null || routeData.polylinePoints.length < 2) {
        emit(TripNavigationError(
          AppMessages.current.tripNavNoRoute,
        ));
        return;
      }

      _activeRoute = routeData;
      _routeSubscription?.cancel();
      _routePollingService.startPolling();
      _routeSubscription = _routePollingService.updates.listen(
        _onRouteUpdate,
        onError: (error, stackTrace) {
          AppLogger.instance.w(
            'TripNavigationCubit: route polling failed',
            error: error,
            stackTrace: stackTrace,
          );
          emit(TripNavigationError(
            AppMessages.current.tripNavLiveUpdatesFailed,
          ));
        },
      );

      emit(TripNavigationNavigating(
        routeData: routeData,
        currentLocation: currentLocation,
      ));
      await _navigationService.speakInstruction(routeData.nextInstruction);
    } catch (e, stackTrace) {
      AppErrorReporter.record(
        'TripNavigationCubit: failed to start navigation',
        error: e,
        stackTrace: stackTrace,
      );
      emit(TripNavigationError(AppMessages.current.tripNavStartFailed));
    }
  }

  Future<void> stopNavigation() async {
    await _routeSubscription?.cancel();
    _routeSubscription = null;
    _routePollingService.stopPolling();
    await _navigationService.stopNavigation();
    _activeRoute = null;
    emit(const TripNavigationIdle());
  }

  void _onRouteUpdate(RouteUpdate update) {
    final routeData = _activeRoute;
    if (routeData == null) return;

    emit(TripNavigationNavigating(
      routeData: routeData,
      currentLocation: update.location,
      latestUpdate: update,
    ));
  }

  @override
  Future<void> close() async {
    await _routeSubscription?.cancel();
    _routePollingService.stopPolling();
    try {
      await _navigationService.stopNavigation();
    } catch (e, stackTrace) {
      // Closing must always succeed; a TTS or GPS shutdown error is only
      // worth logging.
      AppLogger.instance.w(
        'TripNavigationCubit: stopNavigation failed on close',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return super.close();
  }
}
