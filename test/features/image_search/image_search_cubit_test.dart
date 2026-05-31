import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_state.dart';
import 'package:rahhala_app/features/image_search/domain/services/image_acquisition_service.dart';

class _MockImageSearchRepository extends Mock
    implements ImageSearchRepository {}

class _MockImageAcquisitionService extends Mock
    implements ImageAcquisitionService {}

void main() {
  late _MockImageSearchRepository repository;
  late _MockImageAcquisitionService imageAcquisitionService;

  const response = ImageSearchResponse(
    success: true,
    labels: ['museum'],
    places: [],
  );

  setUp(() {
    repository = _MockImageSearchRepository();
    imageAcquisitionService = _MockImageAcquisitionService();
  });

  ImageSearchCubit buildCubit() => ImageSearchCubit(
        repository: repository,
        imageAcquisitionService: imageAcquisitionService,
      );

  blocTest<ImageSearchCubit, ImageSearchState>(
    'searchByPath emits loading then success',
    build: () {
      when(() => repository.searchByImage('photo.jpg')).thenAnswer(
        (_) async => const Right(response),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.searchByPath('photo.jpg'),
    expect: () => [
      isA<ImageSearchLoading>(),
      isA<ImageSearchSuccess>().having((state) => state.result, 'result',
          same(response)),
    ],
  );

  blocTest<ImageSearchCubit, ImageSearchState>(
    'pickFromGalleryAndSearch uses ImageAcquisitionService',
    build: () {
      when(() => imageAcquisitionService.pickFromGallery()).thenAnswer(
        (_) async => File('gallery.jpg'),
      );
      when(() => repository.searchByImage('gallery.jpg')).thenAnswer(
        (_) async => const Right(response),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.pickFromGalleryAndSearch(),
    expect: () => [
      isA<ImageSearchLoading>(),
      isA<ImageSearchSuccess>(),
    ],
    verify: (_) {
      verify(() => imageAcquisitionService.pickFromGallery()).called(1);
      verify(() => repository.searchByImage('gallery.jpg')).called(1);
    },
  );

  blocTest<ImageSearchCubit, ImageSearchState>(
    'pickFromCameraAndSearch does nothing when user cancels',
    build: () {
      when(() => imageAcquisitionService.captureFromCamera()).thenAnswer(
        (_) async => null,
      );
      return buildCubit();
    },
    act: (cubit) => cubit.pickFromCameraAndSearch(),
    expect: () => <ImageSearchState>[],
    verify: (_) {
      verify(() => imageAcquisitionService.captureFromCamera()).called(1);
      verifyNever(() => repository.searchByImage(any()));
    },
  );

  blocTest<ImageSearchCubit, ImageSearchState>(
    'searchByPath emits repository failure message',
    build: () {
      when(() => repository.searchByImage('bad.jpg')).thenAnswer(
        (_) async => Left(ServerFailure(message: 'backend is down')),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.searchByPath('bad.jpg'),
    expect: () => [
      isA<ImageSearchLoading>(),
      isA<ImageSearchFailure>().having(
        (state) => state.message,
        'message',
        'backend is down',
      ),
    ],
  );
}
