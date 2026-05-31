import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/domain/entities/login.dart';
import 'package:rahhala_app/features/auth/domain/usecases/post_login_session_use_case.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Login loginModel;
  final PostLoginSessionResult? session;
  const LoginSuccess({required this.loginModel, this.session});

  @override
  List<Object> get props => [loginModel];
}

class LoginFailure extends LoginState {
  final String errorMessage;
  const LoginFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
