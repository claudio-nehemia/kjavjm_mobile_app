import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.token,
    super.phone,
    super.address,
    super.city,
    super.postalCode,
    super.status,
    super.profilePicture,
    super.photoUrl,
    super.role,
    super.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if the response has 'user' object (from login response)
    if (json.containsKey('user')) {
      final userJson = json['user'] as Map<String, dynamic>;
      return UserModel(
        id: userJson['id'] as int,
        name: userJson['name'] as String,
        email: userJson['email'] as String,
        token: json['access_token'] as String?,
        phone: userJson['phone'] as String?,
        address: userJson['address'] as String?,
        city: userJson['city'] as String?,
        postalCode: userJson['postal_code'] as String?,
        status: userJson['status'] as String?,
        profilePicture: userJson['profile_picture'] as String?,
        photoUrl: userJson['photo_url'] as String?,
        role: userJson['role'] != null 
            ? Role(
                id: userJson['role']['id'] as int,
                name: userJson['role']['name'] as String,
              )
            : null,
        department: userJson['departement'] != null 
            ? Department(
                id: userJson['departement']['id'] as int,
                name: userJson['departement']['name'] as String,
              )
            : null,
      );
    }
    
    // Direct user object (for other endpoints)
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      status: json['status'] as String?,
      profilePicture: json['profile_picture'] as String?,
      photoUrl: json['photo_url'] as String?,
      role: json['role'] != null 
          ? Role(
              id: json['role']['id'] as int,
              name: json['role']['name'] as String,
            )
          : null,
      department: json['departement'] != null 
          ? Department(
              id: json['departement']['id'] as int,
              name: json['departement']['name'] as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'status': status,
      'profile_picture': profilePicture,
      'photo_url': photoUrl,
      'role': role != null ? {'id': role!.id, 'name': role!.name} : null,
      'departement': department != null ? {'id': department!.id, 'name': department!.name} : null,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      token: token,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
      status: status,
      profilePicture: profilePicture,
      photoUrl: photoUrl,
      role: role,
      department: department,
    );
  }
}