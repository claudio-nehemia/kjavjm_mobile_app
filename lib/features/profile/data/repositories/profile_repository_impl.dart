import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Profile> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<Profile> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
  }) async {
    return await remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}