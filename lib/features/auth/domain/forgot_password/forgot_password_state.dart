import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override
  List<Object> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final SuccessMessageModel model;
  const ForgotPasswordSuccess({required this.model});
  @override
  List<Object> get props => [model];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;
  const ForgotPasswordFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}