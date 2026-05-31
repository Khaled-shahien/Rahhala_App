import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/constants/app_colors.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_options.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_state.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/repositories/trip_options_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/trip_option.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'package:rahhala_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_state.dart';
import 'package:rahhala_app/features/image_search/domain/services/image_acquisition_service.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_cubit.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_state.dart';
import 'package:rahhala_app/features/nearby/domain/repositories/nearby_repository.dart';
import 'package:rahhala_app/features/nearby/domain/services/location_service.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockHomeRepository extends Mock implements HomeRepository {}

class _MockImageSearchRepository extends Mock
    implements ImageSearchRepository {}

class _MockGeminiRepository extends Mock implements GeminiRepository {}

class _FakeTripOptionsRepository implements TripOptionsRepository {
  @override
  Future<TripOptionsConfig> getTripOptions() async {
    return const TripOptionsConfig.empty();
  }
}

class _MockNearbyRepository extends Mock implements NearbyRepository {}

class _MockImageAcquisitionService extends Mock
    implements ImageAcquisitionService {}

class _FakeDeniedLocationService implements LocationService {
  @override
  Future<LocationPoint> getCurrentLocation() async {
    throw const LocationServiceException(
      reason: LocationFailureReason.permissionDenied,
      message: 'denied',
    );
  }
}

PlaceModel _place(String id) => PlaceModel(
      id: id,
      name: 'Place $id',
      country: 'Egypt',
      imageUrl: 'https://example.com/$id.jpg',
      isFavourite: false,
    );

void main() {
  group('AuthSessionService', () {
    late _MockTokenStorage tokenStorage;
    late UserSession userSession;
    late AuthSessionService service;

    setUp(() {
      tokenStorage = _MockTokenStorage();
      userSession = UserSession();
      service = AuthSessionService(
        tokenStorage: tokenStorage,
        userSession: userSession,
      );

      when(() => tokenStorage.setToken(any())).thenAnswer((_) async {});
      when(() => tokenStorage.setUsername(any())).thenAnswer((_) async {});
      when(() => tokenStorage.setEmail(any())).thenAnswer((_) async {});
      when(() => tokenStorage.setFullName(any())).thenAnswer((_) async {});
      when(() => tokenStorage.setProfileImageUrl(any()))
          .thenAnswer((_) async {});
      when(() => tokenStorage.clearAll()).thenAnswer((_) async {});
    });

    test('saves session values and mirrors basic user info', () async {
      await service.saveSession(
        token: ' token-123 ',
        username: ' rahhala ',
        email: ' USER@EXAMPLE.COM ',
        fullName: ' Rahhala User ',
        profileImageUrl: ' https://example.com/avatar.jpg ',
      );

      verify(() => tokenStorage.setToken('token-123')).called(1);
      verify(() => tokenStorage.setUsername('rahhala')).called(1);
      verify(() => tokenStorage.setEmail('user@example.com')).called(1);
      verify(() => tokenStorage.setFullName('Rahhala User')).called(1);
      verify(
        () => tokenStorage.setProfileImageUrl('https://example.com/avatar.jpg'),
      ).called(1);
      expect(userSession.email, 'user@example.com');
      expect(userSession.displayName, 'Rahhala User');
      expect(userSession.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('clears token storage and in-memory user session', () async {
      userSession.setFromLogin(
        email: 'user@example.com',
        displayName: 'Rahhala User',
      );

      await service.clearSession();

      verify(() => tokenStorage.clearAll()).called(1);
      expect(userSession.email, isNull);
      expect(userSession.displayName, isNull);
      expect(userSession.avatarUrl, isNull);
    });
  });

  group('Home model and pagination safety', () {
    test('defensively parses malformed home payloads', () {
      final response = HomeResponse.fromJson({
        'success': 'true',
        'page': '2',
        'pageSize': 'bad',
        'youMightAlsoLike': [
          {
            'id': 10,
            'name': null,
            'country': 123,
            'imageUrl': null,
            'isFavourite': '1',
          },
          'bad-item',
        ],
      });

      expect(response.success, isTrue);
      expect(response.page, 2);
      expect(response.pageSize, 8);
      expect(response.places, hasLength(1));
      expect(response.places.first.id, '10');
      expect(response.places.first.name, 'Unknown place');
      expect(response.places.first.country, '123');
      expect(response.places.first.isFavourite, isTrue);
    });

    test('surfaces pagination errors while preserving existing places',
        () async {
      final repository = _MockHomeRepository();
      final firstPage = List.generate(8, (index) => _place('$index'));
      when(() => repository.getHomePlaces(page: 1, pageSize: 8)).thenAnswer(
        (_) async => HomeResponse(
          success: true,
          page: 1,
          pageSize: 8,
          places: firstPage,
        ),
      );
      when(() => repository.getHomePlaces(page: 2, pageSize: 8))
          .thenThrow(Exception('network'));

      final cubit = HomeCubit(repository);
      addTearDown(cubit.close);

      await cubit.getHomeData();
      await cubit.loadMore();

      final state = cubit.state;
      expect(state, isA<HomeSuccess>());
      final success = state as HomeSuccess;
      expect(success.places, hasLength(8));
      expect(success.userMessage, HomeUserMessage.paginationFailed);
    });
  });

  test('nearby cubit maps denied location service to denied state', () async {
    final cubit = NearbyCubit(
      repository: _MockNearbyRepository(),
      locationService: _FakeDeniedLocationService(),
    );
    addTearDown(cubit.close);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<NearbyLocationLoading>(),
        isA<NearbyLocationDenied>(),
      ]),
    );

    await cubit.requestLocationAndLoad();
    await expectation;
  });

  test('image search emits real repository failure message', () async {
    final repository = _MockImageSearchRepository();
    when(() => repository.searchByImage('image.jpg')).thenAnswer(
      (_) async => Left(ServerFailure(message: 'backend is down')),
    );

    final cubit = ImageSearchCubit(
      repository: repository,
      imageAcquisitionService: _MockImageAcquisitionService(),
    );
    addTearDown(cubit.close);

    await cubit.pickAndSearch('image.jpg');

    expect(cubit.state, isA<ImageSearchFailure>());
    expect((cubit.state as ImageSearchFailure).message, 'backend is down');
  });

  test('AI trip day updates are clamped to the supported range', () {
    final cubit = AiTripCubit(
      geminiRepository: _MockGeminiRepository(),
      tripOptionsRepository: _FakeTripOptionsRepository(),
    );
    addTearDown(cubit.close);

    cubit.init();
    cubit.updateDays(99);
    expect((cubit.state as AiTripData).totalDays, AiTripOptions.maxDays);

    cubit.updateDays(0);
    expect((cubit.state as AiTripData).totalDays, AiTripOptions.minDays);
  });

  test('AppColors.lightBackground is a usable color', () {
    expect(AppColors.lightBackground, isA<Color>());
    expect(AppColors.lightBackground, AppColors.backgroundGray);
  });

  test('image search success model remains constructible for mocks', () {
    const response = ImageSearchResponse(
      success: true,
      labels: [],
      places: [],
    );
    expect(response.success, isTrue);
  });
}
