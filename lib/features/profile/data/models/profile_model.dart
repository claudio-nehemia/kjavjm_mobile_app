import '../../domain/entities/profile.dart';

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
    super.photoUrl,
    super.role,
    super.department,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'],
      status: json['status'],
      profilePicture: json['profile_picture'],
      photoUrl: json['photo_url'],
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
      department: json['departement'] != null ? DepartmentModel.fromJson(json['departement']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'status': status,
      'profile_picture': profilePicture,
      'role': role != null ? (role as RoleModel).toJson() : null,
      'departement': department != null ? (department as DepartmentModel).toJson() : null,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? status,
    String? profilePicture,
    Role? role,
    Department? department,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      status: status ?? this.status,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoleModel extends Role {
  const RoleModel({
    required super.id,
    required super.name,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DepartmentModel extends Department {
  const DepartmentModel({
    required super.id,
    required super.name,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}