import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/profile/data/models/user_model_details.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModelDetails details;
  const ProfileLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileActionLoading extends ProfileState {} 

class ProfileActionSuccess extends ProfileState {
  
  final SuccessMessageModel model;
  const ProfileActionSuccess(this.model);
  @override
  List<Object?> get props => [model];
}
