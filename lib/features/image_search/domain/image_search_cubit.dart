import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_state.dart';
import 'package:rahhala_app/features/image_search/domain/services/image_acquisition_service.dart';

class ImageSearchCubit extends Cubit<ImageSearchState> {
  final ImageSearchRepository repository;
  final ImageAcquisitionService imageAcquisitionService;

  ImageSearchCubit({
    required this.repository,
    required this.imageAcquisitionService,
  }) : super(ImageSearchInitial());

  /// Search using a file path directly (e.g. from camera capture).
  Future<void> searchByPath(String path) async {
    try {
      emit(ImageSearchLoading());

      final result = await repository.searchByImage(path);

      result.fold(
        (failure) => emit(ImageSearchFailure(failure.message)),
        (response) => emit(ImageSearchSuccess(response)),
      );
    } catch (e) {
      AppErrorReporter.record('Image search failed', error: e);
      emit(ImageSearchFailure(
        'Could not process the selected image. Please try another photo.',
      ));
    }
  }

  /// Pick an image from the camera and search.
  Future<void> pickFromCameraAndSearch() async {
    try {
      final image = await imageAcquisitionService.captureFromCamera();
      if (image == null) return; // User cancelled

      await searchByPath(image.path);
    } catch (e) {
      AppErrorReporter.record('Camera pick failed', error: e);
      emit(ImageSearchFailure(
        'Could not access the camera. Please try again.',
      ));
    }
  }

  /// Pick an image from the gallery and search.
  Future<void> pickFromGalleryAndSearch() async {
    try {
      final image = await imageAcquisitionService.pickFromGallery();
      if (image == null) return; // User cancelled

      await searchByPath(image.path);
    } catch (e) {
      AppErrorReporter.record('Gallery pick failed', error: e);
      emit(ImageSearchFailure(
        'Could not access the gallery. Please try again.',
      ));
    }
  }

  /// Backward-compatible method: accepts a file path string.
  ///
  /// This preserves the existing call site in [PinterestCameraScreen]
  /// which passes a path directly.
  Future<void> pickAndSearch(String path) => searchByPath(path);

  void reset() => emit(ImageSearchInitial());
}
