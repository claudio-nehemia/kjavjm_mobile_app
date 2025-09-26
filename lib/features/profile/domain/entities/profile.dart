class Profile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String status;
  final String? profilePicture;
  final Role? role;
  final Department? department;
  final String createdAt;
  final String updatedAt;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    required this.status,
    this.profilePicture,
    this.role,
    this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          address == other.address &&
          city == other.city &&
          postalCode == other.postalCode &&
          status == other.status &&
          profilePicture == other.profilePicture &&
          role == other.role &&
          department == other.department &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      city.hashCode ^
      postalCode.hashCode ^
      status.hashCode ^
      profilePicture.hashCode ^
      role.hashCode ^
      department.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Profile{id: $id, name: $name, email: $email, phone: $phone, address: $address, city: $city, postalCode: $postalCode, status: $status, profilePicture: $profilePicture, role: $role, department: $department, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

class Role {
  final int id;
  final String name;

  const Role({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Role{id: $id, name: $name}';
}

class Department {
  final int id;
  final String name;

  const Department({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Department{id: $id, name: $name}';
}