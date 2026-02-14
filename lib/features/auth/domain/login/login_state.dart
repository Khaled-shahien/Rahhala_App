import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/data/models/login_model.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Login loginModel;
  const LoginSuccess({required this.loginModel});

  @override
  List<Object> get props => [loginModel];
}

class LoginFailure extends LoginState {
  final String errorMessage;
  const LoginFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}