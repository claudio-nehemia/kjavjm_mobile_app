import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  final Profile profile;

  const ProfileUpdateSuccess({
    required this.message,
    required this.profile,
  });

  @override
  List<Object> get props => [message, profile];
}

class PasswordChangeSuccess extends ProfileState {
  final String message;

  const PasswordChangeSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}