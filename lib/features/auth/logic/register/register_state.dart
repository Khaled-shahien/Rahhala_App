import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final SuccessMessageModel model;
  const RegisterSuccess({required this.model});
  @override
  List<Object> get props => [model];
}

class RegisterFailure extends RegisterState {
  final String errorMessage;
  const RegisterFailure({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}