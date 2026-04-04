import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/trip_history/data/models/trip_history_model.dart';

abstract class TripHistoryState extends Equatable {
  const TripHistoryState();

  @override
  List<Object?> get props => [];
}

class TripHistoryInitial extends TripHistoryState {}

class TripHistoryLoading extends TripHistoryState {}

class TripHistoryLoaded extends TripHistoryState {
  final TripHistoryResponse response;

  const TripHistoryLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class TripHistoryFailure extends TripHistoryState {
  final String message;

  const TripHistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TripHistoryDetailLoading extends TripHistoryState {}

class TripHistoryDetailLoaded extends TripHistoryState {
  final TripHistoryDetailResponse response;

  const TripHistoryDetailLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class TripHistoryDetailFailure extends TripHistoryState {
  final String message;

  const TripHistoryDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TripRegenerateLoading extends TripHistoryState {}

class TripRegenerateSuccess extends TripHistoryState {
  final TripHistoryDetailResponse response;

  const TripRegenerateSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class TripRegenerateFailure extends TripHistoryState {
  final String message;

  const TripRegenerateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
