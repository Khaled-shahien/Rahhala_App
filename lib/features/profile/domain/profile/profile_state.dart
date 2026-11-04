import 'package:equatable/equatable.dart';
import 'package:rahhala_app/features/profile/domain/entities/user_details.dart';
import 'package:rahhala_app/features/auth/domain/entities/success_message.dart';

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

/// The account was deleted on the server. The UI must end the session.
class ProfileAccountDeleted extends ProfileState {
  final SuccessMessageModel model;
  const ProfileAccountDeleted(this.model);
  @override
  List<Object?> get props => [model];
}

/// There's no signed-in user (guest mode), so no profile is fetched.
class ProfileGuest extends ProfileState {
  const ProfileGuest();
}
