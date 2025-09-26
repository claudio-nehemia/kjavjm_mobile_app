import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<Profile> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}