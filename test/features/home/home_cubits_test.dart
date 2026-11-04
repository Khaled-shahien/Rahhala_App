import 'dart:async';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/errors/error_model.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'package:rahhala_app/features/home/presentation/cubit/favourites_cubit.dart';
import 'package:rahhala_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

class _MockHomeRepository extends Mock implements HomeRepository {}

PlaceModel _place(String id, {bool favourite = false}) => PlaceModel(
      id: id,
      name: 'Place $id',
      country: 'Egypt',
      imageUrl: '',
      isFavourite: favourite,
    );

HomeResponse _page(List<PlaceModel> places, {int page = 1}) => HomeResponse(
      success: true,
      page: page,
      pageSize: 8,
      places: places,
    );

List<PlaceModel> _places(int from, int count) =>
    List.generate(count, (i) => _place('${from + i}'));

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  late _MockHomeRepository repository;

  setUp(() {
    AppMessages.localeResolver = () => const Locale('en');
    repository = _MockHomeRepository();
  });

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'shows a localized message instead of exception text',
      build: () {
        when(() => repository.getHomePlaces(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(const ServerException(
          errorModel: ErrorModel(
            message: 'No internet connection.',
            type: FailureType.network,
          ),
        ));
        return HomeCubit(repository);
      },
      act: (cubit) => cubit.getHomeData(),
      verify: (cubit) {
        final state = cubit.state as HomeError;
        expect(state.message, 'No internet connection.');
        expect(state.message, isNot(contains('Instance of')));
      },
    );

    blocTest<HomeCubit, HomeState>(
      'maps unexpected parsing errors to a generic message',
      build: () {
        when(() => repository.getHomePlaces(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(TypeError());
        return HomeCubit(repository);
      },
      act: (cubit) => cubit.getHomeData(),
      verify: (cubit) =>
          expect((cubit.state as HomeError).message, en.errorParsing),
    );

    test('a refresh discards a load-more response that arrives late',
        () async {
      final slowPage2 = Completer<HomeResponse>();
      when(() => repository.getHomePlaces(page: 1, pageSize: 8))
          .thenAnswer((_) async => _page(_places(0, 8)));
      when(() => repository.getHomePlaces(page: 2, pageSize: 8))
          .thenAnswer((_) => slowPage2.future);

      final cubit = HomeCubit(repository);
      await cubit.getHomeData();
      final loadMore = cubit.loadMore();
      await cubit.getHomeData(); // pull-to-refresh while page 2 is loading
      slowPage2.complete(_page(_places(100, 8), page: 2));
      await loadMore;

      final state = cubit.state as HomeSuccess;
      expect(state.places.map((p) => p.id), _places(0, 8).map((p) => p.id));
      await cubit.close();
    });

    test('load more appends new places and skips duplicates', () async {
      when(() => repository.getHomePlaces(page: 1, pageSize: 8))
          .thenAnswer((_) async => _page(_places(0, 8)));
      when(() => repository.getHomePlaces(page: 2, pageSize: 8)).thenAnswer(
          (_) async => _page([..._places(7, 1), ..._places(8, 3)], page: 2));

      final cubit = HomeCubit(repository);
      await cubit.getHomeData();
      await cubit.loadMore();

      final state = cubit.state as HomeSuccess;
      expect(state.places.length, 11);
      expect(state.hasMore, isFalse);
      await cubit.close();
    });

    test('a failed favourite toggle rolls back and reports it', () async {
      when(() => repository.getHomePlaces(page: 1, pageSize: 8))
          .thenAnswer((_) async => _page([_place('a')]));
      when(() => repository.addFavourite('a'))
          .thenThrow(Exception('offline'));

      final cubit = HomeCubit(repository);
      await cubit.getHomeData();
      await cubit.toggleFavourite('a', false);

      final state = cubit.state as HomeSuccess;
      expect(state.places.single.isFavourite, isFalse);
      expect(state.userMessage, HomeUserMessage.favouriteFailed);
      await cubit.close();
    });

    test('rapid taps on the same favourite send one request', () async {
      final pending = Completer<void>();
      when(() => repository.getHomePlaces(page: 1, pageSize: 8))
          .thenAnswer((_) async => _page([_place('a')]));
      when(() => repository.addFavourite('a'))
          .thenAnswer((_) => pending.future);

      final cubit = HomeCubit(repository);
      await cubit.getHomeData();
      final first = cubit.toggleFavourite('a', false);
      await cubit.toggleFavourite('a', true);
      pending.complete();
      await first;

      verify(() => repository.addFavourite('a')).called(1);
      verifyNever(() => repository.removeFavourite('a'));
      await cubit.close();
    });
  });

  group('FavouritesCubit', () {
    blocTest<FavouritesCubit, FavouritesState>(
      'asks the user to log in only for unauthorized failures',
      build: () {
        when(() => repository.getFavourites()).thenThrow(
          const ServerException(
            errorModel: ErrorModel(
              message: 'expired',
              statusCode: 401,
              type: FailureType.unauthorized,
            ),
          ),
        );
        return FavouritesCubit(repository);
      },
      act: (cubit) => cubit.getFavourites(),
      verify: (cubit) {
        final state = cubit.state as FavouritesError;
        expect(state.requiresLogin, isTrue);
        expect(state.message, en.favouritesLoginRequired);
      },
    );

    blocTest<FavouritesCubit, FavouritesState>(
      'shows the network message for connectivity failures',
      build: () {
        when(() => repository.getFavourites()).thenThrow(
          const ServerException(
            errorModel: ErrorModel(
              message: 'No internet connection.',
              type: FailureType.network,
            ),
          ),
        );
        return FavouritesCubit(repository);
      },
      act: (cubit) => cubit.getFavourites(),
      verify: (cubit) {
        final state = cubit.state as FavouritesError;
        expect(state.requiresLogin, isFalse);
        expect(state.message, 'No internet connection.');
      },
    );

    test('removing restores the item when the request fails', () async {
      final favourite = FavouriteModel(
        id: 'p1',
        name: 'Luxor',
        country: 'Egypt',
        imageUrl: '',
        rating: 4.5,
        createdAt: '',
      );
      when(() => repository.getFavourites())
          .thenAnswer((_) async => [favourite]);
      when(() => repository.removeFavourite('p1'))
          .thenThrow(Exception('offline'));

      final cubit = FavouritesCubit(repository);
      await cubit.getFavourites();
      await cubit.removeFavourite('p1');

      final state = cubit.state as FavouritesSuccess;
      expect(state.favourites.single.id, 'p1');
      expect(state.message, en.favouritesRemoveFailed);
      await cubit.close();
    });
  });
}
