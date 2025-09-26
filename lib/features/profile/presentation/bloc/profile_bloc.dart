import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart' as update_usecase;
import '../../domain/usecases/change_password.dart' as password_usecase;
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final update_usecase.UpdateProfile updateProfile;
  final password_usecase.ChangePassword changePassword;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.changePassword,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());
      final profile = await getProfile();
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());
      final updatedProfile = await updateProfile(
        name: event.name,
        phone: event.phone,
        address: event.address,
        city: event.city,
        postalCode: event.postalCode,
      );
      emit(ProfileUpdateSuccess(
        message: 'Profile updated successfully',
        profile: updatedProfile,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());
      await changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(const PasswordChangeSuccess(
        message: 'Password changed successfully',
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}