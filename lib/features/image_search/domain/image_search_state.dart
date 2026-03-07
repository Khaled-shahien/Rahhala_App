import 'package:rahhala_app/features/image_search/data/models/image_search_model.dart';

abstract class ImageSearchState {}

class ImageSearchInitial extends ImageSearchState {}

class ImageSearchLoading extends ImageSearchState {}

class ImageSearchSuccess extends ImageSearchState {
  final ImageSearchResponse result;
  ImageSearchSuccess(this.result);
}

class ImageSearchFailure extends ImageSearchState {
  final String message;
  ImageSearchFailure(this.message);
}
