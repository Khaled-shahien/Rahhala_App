import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/features/home/data/models/home_model.dart';
import '../../domain/repositories/home_repository.dart';

enum ReviewAction { add, update, delete }

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewActionLoading extends ReviewState {
  final ReviewAction action;
  ReviewActionLoading(this.action);
}

class ReviewSuccess extends ReviewState {
  final ReviewAction action;
  final String message;
  ReviewSuccess({required this.action, required this.message});
}

class ReviewError extends ReviewState {
  final String message;
  final ReviewAction action;
  ReviewError({required this.message, required this.action});
}

class ReviewCubit extends Cubit<ReviewState> {
  final HomeRepository repository;
  ReviewCubit(this.repository) : super(ReviewInitial());

  Future<void> submitReview(String placeId, String comment, int rating) async {
    emit(ReviewActionLoading(ReviewAction.add));
    try {
      await repository.addReview(
          placeId, ReviewRequest(comment: comment, rating: rating));
      emit(ReviewSuccess(
        action: ReviewAction.add,
        message: 'Your review has been submitted successfully!',
      ));
    } catch (e) {
      emit(ReviewError(
        action: ReviewAction.add,
        message: 'Please log in to share your review!',
      ));
    }
  }

  Future<void> updateReview(String reviewId, String comment, int rating) async {
    emit(ReviewActionLoading(ReviewAction.update));
    try {
      await repository.updateReview(
        reviewId,
        ReviewRequest(comment: comment, rating: rating),
      );
      emit(ReviewSuccess(
        action: ReviewAction.update,
        message: 'Your review has been updated successfully!',
      ));
    } catch (e) {
      emit(ReviewError(
        action: ReviewAction.update,
        message: 'Unable to update review. Please try again.',
      ));
    }
  }

  Future<void> deleteReview(String reviewId) async {
    emit(ReviewActionLoading(ReviewAction.delete));
    try {
      await repository.deleteReview(reviewId);
      emit(ReviewSuccess(
        action: ReviewAction.delete,
        message: 'Your review has been deleted successfully!',
      ));
    } catch (e) {
      emit(ReviewError(
        action: ReviewAction.delete,
        message: 'Unable to delete review. Please try again.',
      ));
    }
  }
}
