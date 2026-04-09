import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import '../../domain/repositories/home_repository.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSuccess extends ReviewState {}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}

class ReviewCubit extends Cubit<ReviewState> {
  final HomeRepository repository;
  ReviewCubit(this.repository) : super(ReviewInitial());

  Future<void> submitReview(String placeId, String comment, int rating) async {
    emit(ReviewLoading());
    try {
      await repository.addReview(
          placeId, ReviewRequest(comment: comment, rating: rating));
      emit(ReviewSuccess());
    } catch (e) {
      emit(ReviewError("Please log in to share your review!"));
    }
  }
}
