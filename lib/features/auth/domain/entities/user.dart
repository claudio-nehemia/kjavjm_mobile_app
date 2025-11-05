import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? status;
  final String? profilePicture;
  final String? photoUrl;
  final Role? role;
  final Department? department;
  final UserStatistics? statistics;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.status,
    this.profilePicture,
    this.photoUrl,
    this.role,
    this.department,
    this.statistics,
  });

  @override
  List<Object?> get props => [
    id, name, email, token, phone, address, city, 
    postalCode, status, profilePicture, photoUrl, role, department, statistics
  ];

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
      'role': role?.toJson(),
      'department': department?.toJson(),
      'statistics': statistics?.toJson(),
    };
  }
}

class Role extends Equatable {
  final int id;
  final String name;

  const Role({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Department extends Equatable {
  final int id;
  final String name;

  const Department({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class UserStatistics extends Equatable {
  final int totalPresent;
  final int totalLeave;
  final int totalAbsent;
  final int month;
  final int year;

  const UserStatistics({
    required this.totalPresent,
    required this.totalLeave,
    required this.totalAbsent,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [totalPresent, totalLeave, totalAbsent, month, year];

  Map<String, dynamic> toJson() {
    return {
      'total_present': totalPresent,
      'total_leave': totalLeave,
      'total_absent': totalAbsent,
      'month': month,
      'year': year,
    };
  }
}