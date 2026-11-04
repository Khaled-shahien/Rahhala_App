import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';

abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();
  @override
  List<Object> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {
  final SuccessMessageModel model;
  const ResetPasswordSuccess({required this.model});
  @override
  List<Object> get props => [model];
}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;
  const ResetPasswordFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
