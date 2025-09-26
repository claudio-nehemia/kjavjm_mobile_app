import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;

  const UpdateProfile({
    required this.name,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
  });

  @override
  List<Object?> get props => [name, phone, address, city, postalCode];
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}