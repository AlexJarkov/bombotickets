import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileState {
  final String fullName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String idNumber; // Carnet/NIT
  final String? address; // Opcional
  final String accountNumber;
  final String bankName;
  final String? photoPath; // Ruta local de la foto

  const ProfileState({
    this.fullName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.idNumber = '',
    this.address,
    this.accountNumber = '',
    this.bankName = '',
    this.photoPath,
  });

  ProfileState copyWith({
    String? fullName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? idNumber,
    String? address,
    String? accountNumber,
    String? bankName,
    String? photoPath,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  static const _kFullName = 'profile.fullName';
  static const _kLastName = 'profile.lastName';
  static const _kEmail = 'profile.email';
  static const _kPhoneNumber = 'profile.phoneNumber';
  static const _kIdNumber = 'profile.idNumber';
  static const _kAddress = 'profile.address';
  static const _kAccountNumber = 'profile.accountNumber';
  static const _kBankName = 'profile.bankName';
  static const _kPhotoPath = 'profile.photoPath';

  ProfileNotifier() : super(const ProfileState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      fullName: prefs.getString(_kFullName) ?? '',
      lastName: prefs.getString(_kLastName) ?? '',
      email: prefs.getString(_kEmail) ?? '',
      phoneNumber: prefs.getString(_kPhoneNumber) ?? '',
      idNumber: prefs.getString(_kIdNumber) ?? '',
      address: prefs.getString(_kAddress),
      accountNumber: prefs.getString(_kAccountNumber) ?? '',
      bankName: prefs.getString(_kBankName) ?? '',
      photoPath: prefs.getString(_kPhotoPath),
    );
  }

  Future<void> updateProfile(ProfileState newState) async {
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFullName, state.fullName);
    await prefs.setString(_kLastName, state.lastName);
    await prefs.setString(_kEmail, state.email);
    await prefs.setString(_kPhoneNumber, state.phoneNumber);
    await prefs.setString(_kIdNumber, state.idNumber);
    if (state.address == null || state.address!.isEmpty) {
      await prefs.remove(_kAddress);
    } else {
      await prefs.setString(_kAddress, state.address!);
    }
    await prefs.setString(_kAccountNumber, state.accountNumber);
    await prefs.setString(_kBankName, state.bankName);
    if (state.photoPath == null || state.photoPath!.isEmpty) {
      await prefs.remove(_kPhotoPath);
    } else {
      await prefs.setString(_kPhotoPath, state.photoPath!);
    }
  }

  Future<void> setPhotoPath(String? path) async {
    state = state.copyWith(photoPath: path);
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_kPhotoPath);
    } else {
      await prefs.setString(_kPhotoPath, path);
    }
  }
}

