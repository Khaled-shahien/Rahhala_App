import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class VerifyOtpState extends Equatable {
  const VerifyOtpState();
  @override
  List<Object> get props => [];
}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpLoading extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final SuccessMessageModel model;
  const VerifyOtpSuccess({required this.model});
  @override
  List<Object> get props => [model];
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;
  const VerifyOtpFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}