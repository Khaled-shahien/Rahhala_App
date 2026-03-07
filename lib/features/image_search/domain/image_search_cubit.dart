import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_state.dart';

class ImageSearchCubit extends Cubit<ImageSearchState> {
  final ImageSearchRepository repository;
  final ImagePicker _picker = ImagePicker();

  ImageSearchCubit({required this.repository}) : super(ImageSearchInitial());

  Future<void> pickAndSearch(dynamic source) async {
    try {
      String? path;

      if (source is String) {
        path = source;
      } else if (source is ImageSource) {
        final XFile? file = await _picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1080,
        );
        if (file == null) return;
        path = file.path;
      } else {
        return;
      }

      emit(ImageSearchLoading());

      final result = await repository.searchByImage(path);

      result.fold(
        (failure) => emit(ImageSearchFailure(failure.message)),
        (response) => emit(ImageSearchSuccess(response)),
      );
    } catch (e) {
      emit(ImageSearchFailure('Failed to process image'));
    }
  }

  void reset() => emit(ImageSearchInitial());
}
