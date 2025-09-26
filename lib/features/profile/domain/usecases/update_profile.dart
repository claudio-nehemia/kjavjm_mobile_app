import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Profile> call({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
  }) async {
    return await repository.updateProfile(
      name: name,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
    );
  }
}