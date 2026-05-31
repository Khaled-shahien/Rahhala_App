import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/navigation_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_polling_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_update.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/trip_navigation_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_route_helpers.dart';

class _MockNavigationService extends Mock implements NavigationService {}

class _FakeRoutePollingService implements RoutePollingService {
  final StreamController<RouteUpdate> _controller =
      StreamController<RouteUpdate>.broadcast();

  bool started = false;
  bool stopped = false;

  @override
  Stream<RouteUpdate> get updates => _controller.stream;

  @override
  void startPolling() {
    started = true;
  }

  @override
  void stopPolling() {
    stopped = true;
  }

  void add(RouteUpdate update) => _controller.add(update);

  Future<void> close() => _controller.close();
}

TripRouteResponseData _routeData() => const TripRouteResponseData(
      polylinePoints: [LatLng(30.0, 31.0), LatLng(30.1, 31.1)],
      totalDistance: '2 km',
      totalDuration: '8 mins',
      nextInstruction: 'Go straight',
      nextInstructionDuration: '2 mins',
      steps: [],
    );

void main() {
  late _MockNavigationService navigationService;
  late _FakeRoutePollingService routePollingService;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    navigationService = _MockNavigationService();
    routePollingService = _FakeRoutePollingService();
    when(() => navigationService.stopNavigation()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await routePollingService.close();
  });

  TripNavigationCubit buildCubit() => TripNavigationCubit(
        navigationService: navigationService,
        routePollingService: routePollingService,
      );

  blocTest<TripNavigationCubit, TripNavigationState>(
    'emits error when there is no destination',
    build: buildCubit,
    act: (cubit) => cubit.startNavigation(const [LatLng(30, 31)]),
    expect: () => [
      isA<TripNavigationError>().having(
        (state) => state.message,
        'message',
        contains('destination'),
      ),
    ],
  );

  blocTest<TripNavigationCubit, TripNavigationState>(
    'starts navigation and speaks the first instruction',
    build: () {
      when(() => navigationService.startNavigation()).thenAnswer(
        (_) async => const LatLng(30, 31),
      );
      when(
        () => navigationService.requestRoute(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => _routeData());
      when(() => navigationService.speakInstruction(any()))
          .thenAnswer((_) async {});
      when(() => navigationService.stopNavigation()).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (cubit) => cubit.startNavigation(
      const [LatLng(30.1, 31.1), LatLng(30.2, 31.2)],
    ),
    expect: () => [
      const TripNavigationLoading(),
      isA<TripNavigationNavigating>().having(
        (state) => state.currentLocation,
        'currentLocation',
        const LatLng(30, 31),
      ),
    ],
    verify: (_) {
      expect(routePollingService.started, isTrue);
      verify(() => navigationService.speakInstruction('Go straight'))
          .called(1);
    },
  );

  blocTest<TripNavigationCubit, TripNavigationState>(
    'emits live updates from RoutePollingService',
    build: () {
      when(() => navigationService.startNavigation()).thenAnswer(
        (_) async => const LatLng(30, 31),
      );
      when(
        () => navigationService.requestRoute(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => _routeData());
      when(() => navigationService.speakInstruction(any()))
          .thenAnswer((_) async {});
      when(() => navigationService.stopNavigation()).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.startNavigation(
        const [LatLng(30.1, 31.1), LatLng(30.2, 31.2)],
      );
      routePollingService.add(
        const RouteUpdate(
          location: LatLng(30.05, 31.05),
          speedMetersPerSecond: 5,
        ),
      );
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      const TripNavigationLoading(),
      isA<TripNavigationNavigating>(),
      isA<TripNavigationNavigating>().having(
        (state) => state.latestUpdate?.speedMetersPerSecond,
        'speed',
        5,
      ),
    ],
  );
}
