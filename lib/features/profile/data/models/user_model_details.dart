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
      ];

  @override
  String toString() {
    return 'UserModelDetails(id: $id, fullName: $fullName, email: $email, profileImageUrl: $profileImageUrl)';
  }
}
