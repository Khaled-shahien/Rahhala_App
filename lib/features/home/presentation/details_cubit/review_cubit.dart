import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rahhala_app/core/errors/exceptions.dart';
import 'package:rahhala_app/core/errors/failures.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
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
    if (state is ReviewActionLoading) return;
    emit(ReviewActionLoading(ReviewAction.add));
    try {
      await repository.addReview(
          placeId, ReviewRequest(comment: comment, rating: rating));
      if (isClosed) return;
      emit(ReviewSuccess(
        action: ReviewAction.add,
        message: AppMessages.current.reviewSubmitted,
      ));
    } catch (e) {
      if (isClosed) return;
      final failure = failureFromError(e);
      emit(ReviewError(
        action: ReviewAction.add,
        message: failure.type == FailureType.unauthorized
            ? AppMessages.current.reviewLoginRequired
            : failure.message,
      ));
    }
  }

  Future<void> updateReview(String reviewId, String comment, int rating) async {
    if (state is ReviewActionLoading) return;
    emit(ReviewActionLoading(ReviewAction.update));
    try {
      await repository.updateReview(
        reviewId,
        ReviewRequest(comment: comment, rating: rating),
      );
      if (isClosed) return;
      emit(ReviewSuccess(
        action: ReviewAction.update,
        message: AppMessages.current.reviewUpdated,
      ));
    } catch (e) {
      if (isClosed) return;
      final failure = failureFromError(e);
      emit(ReviewError(
        action: ReviewAction.update,
        message: failure.isConnectivity
            ? failure.message
            : AppMessages.current.reviewUpdateFailed,
      ));
    }
  }

  Future<void> deleteReview(String reviewId) async {
    if (state is ReviewActionLoading) return;
    emit(ReviewActionLoading(ReviewAction.delete));
    try {
      await repository.deleteReview(reviewId);
      if (isClosed) return;
      emit(ReviewSuccess(
        action: ReviewAction.delete,
        message: AppMessages.current.reviewDeleted,
      ));
    } catch (e) {
      if (isClosed) return;
      final failure = failureFromError(e);
      emit(ReviewError(
        action: ReviewAction.delete,
        message: failure.isConnectivity
            ? failure.message
            : AppMessages.current.reviewDeleteFailed,
      ));
    }
  }
}
