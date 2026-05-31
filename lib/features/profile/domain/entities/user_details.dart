import 'package:equatable/equatable.dart';

class UserModelDetails extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? countryId;
  final String? countryName;
  final DateTime? createdAt;
  final String? gender; // Added gender property
  final DateTime?
      birthDate; // Changed from dateOfBirth to birthDate and use DateTime

  const UserModelDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.countryId,
    this.countryName,
    this.createdAt,
    this.gender, // Added gender parameter
    this.birthDate, // Changed to birthDate
  });

  factory UserModelDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['result'] ?? json;

    String fullName = '';
    final fName = data['firstName']?.toString().trim() ?? '';
    final lName = data['lastName']?.toString().trim() ?? '';

    if (fName.isNotEmpty && lName.isNotEmpty) {
      fullName = '$fName $lName';
    } else if (fName.isNotEmpty) {
      fullName = fName;
    } else if (lName.isNotEmpty) {
      fullName = lName;
    } else {
      fullName = data['fullName']?.toString().trim() ??
          data['name']?.toString().trim() ??
          data['username']?.toString().trim() ??
          '';
    }

    String? imageUrl = data['profileImageUrl']?.toString().trim() ??
        data['profileImage']?.toString().trim() ??
        data['imageUrl']?.toString().trim() ??
        data['avatar']?.toString().trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http')) {
        imageUrl = 'https://rahhallaweb2026.runasp.net$imageUrl';
      }
    }

    DateTime? createdDate;
    final dateStr = data['createdAt']?.toString() ??
        data['created_at']?.toString() ??
        data['registeredAt']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        createdDate = DateTime.parse(dateStr);
      } catch (e) {
        createdDate = null;
      }
    }

    // Parse birthDate from birthofdate field (exact backend name)
    DateTime? parsedBirthDate;
    final birthDateStr =
        data['birthofdate']?.toString(); // Exact backend field name
    if (birthDateStr != null && birthDateStr.isNotEmpty) {
      try {
        // Handle the format "yyyy-MM-ddTHH:mm:ss"
        parsedBirthDate = DateTime.parse(birthDateStr);
      } catch (e) {
        // If parsing fails, try to parse just the date part
        try {
          final datePart = birthDateStr.split('T')[0];
          parsedBirthDate = DateTime.parse(datePart);
        } catch (e2) {
          parsedBirthDate = null;
        }
      }
    }

    return UserModelDetails(
      id: data['id']?.toString() ?? '',
      firstName: fName,
      lastName: lName,
      fullName: fullName,
      email: data['email']?.toString().trim().toLowerCase() ?? '',
      phoneNumber: data['phoneNumber']?.toString().trim() ??
          data['phone']?.toString().trim(),
      profileImageUrl: imageUrl,
      countryId:
          data['countryId']?.toString() ?? data['country_id']?.toString(),
      countryName:
          data['countryName']?.toString() ?? data['country']?.toString(),
      createdAt: createdDate,
      gender: data['gender']?.toString().trim(), // Added gender
      birthDate: parsedBirthDate, // Use parsed birthDate
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'countryId': countryId,
      'countryName': countryName,
      'createdAt': createdAt?.toIso8601String(),
      'gender': gender, // Added gender
      'birthofdate': birthDate?.toIso8601String(), // Use backend field name
    };
  }

  UserModelDetails copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? countryId,
    String? countryName,
    DateTime? createdAt,
    String? gender, // Added gender
    DateTime? birthDate, // Changed to birthDate
  }) {
    return UserModelDetails(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      createdAt: createdAt ?? this.createdAt,
      gender: gender ?? this.gender, // Added gender
      birthDate: birthDate ?? this.birthDate, // Changed to birthDate
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fullName,
        email,
        phoneNumber,
        profileImageUrl,
        countryId,
        countryName,
        createdAt,
        gender, // Added gender
        birthDate, // Changed to birthDate
      ];

  @override
  String toString() {
    return 'UserModelDetails(id: $id, fullName: $fullName, email: $email, profileImageUrl: $profileImageUrl, gender: $gender, birthDate: $birthDate)';
  }
}
