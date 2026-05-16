import 'package:flutter/material.dart';

/// Mutable user profile — all editable fields live here.
/// Name and CNIC are locked (identity-verified) and cannot be changed.
class UserProfile {
  String fullName;
  String cnic;

  // Editable fields
  String altPhone;
  String email;
  String address;
  String district;
  String city;
  String avatarUrl;

  UserProfile({
    this.fullName = '',
    this.cnic = '',
    this.altPhone = '',
    this.email = '',
    this.address = '',
    this.district = '',
    this.city = '',
    this.avatarUrl = '',
  });
}

/// Global singleton — shared between ProfileScreen and EditProfileScreen.
class UserProfileStore extends ChangeNotifier {
  UserProfileStore._();
  static final UserProfileStore instance = UserProfileStore._();

  final UserProfile profile = UserProfile();

  void saveEdits({
    required String altPhone,
    required String email,
    required String address,
    required String district,
    required String city,
  }) {
    profile
      ..altPhone = altPhone.trim()
      ..email = email.trim()
      ..address = address.trim()
      ..district = district
      ..city = city.trim();
    notifyListeners();
  }

  void updateFromMap(Map<String, dynamic> data) {
    if (data['full_name'] != null) profile.fullName = data['full_name'];
    if (data['cnic'] != null) profile.cnic = data['cnic'];
    if (data['phone'] != null) profile.altPhone = data['phone'];
    if (data['email'] != null) profile.email = data['email'];
    if (data['address'] != null) profile.address = data['address'];
    if (data['avatar_url'] != null) profile.avatarUrl = data['avatar_url'];
    if (data['profile_picture'] != null) profile.avatarUrl = data['profile_picture'];
    notifyListeners();
  }
}
