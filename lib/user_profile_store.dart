import 'package:flutter/material.dart';

/// Mutable user profile — all editable fields live here.
/// Name and CNIC are locked (identity-verified) and cannot be changed.
class UserProfile {
  // Identity-locked (read-only in the UI)
  final String fullName;
  final String cnic;

  // Editable fields
  String altPhone;
  String email;
  String address;
  String district;
  String city;

  UserProfile({
    this.fullName = 'Muhammad Ahmed Khan',
    this.cnic = '42101-1234567-8',
    this.altPhone = '',
    this.email = '',
    this.address = '',
    this.district = '',
    this.city = '',
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
}
