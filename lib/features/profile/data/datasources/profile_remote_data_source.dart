import '../../domain/entities/profile.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({
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

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // Implementation will be added
  
  @override
  Future<ProfileModel> getProfile() {
    // TODO: implement getProfile
    throw UnimplementedError();
  }
  
  @override
  Future<ProfileModel> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
  }) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }
  
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }
}

// Import ProfileModel
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.address,
    super.city,
    super.postalCode,
    required super.status,
    super.profilePicture,
    super.role,
    super.department,
    required super.createdAt,
    required super.updatedAt,
  });
}