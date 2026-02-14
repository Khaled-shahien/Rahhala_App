import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/auth/data/models/success_message_model.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();
  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final SuccessMessageModel model;
  const EditProfileSuccess(this.model);
  @override
  List<Object?> get props => [model];
}

class EditProfileFailure extends EditProfileState {
  final String message;
  const EditProfileFailure(this.message);
  @override
  List<Object?> get props => [message];
}
