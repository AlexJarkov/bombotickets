import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/features/profile/repositories/profile_repository.dart';
import 'package:bombotickets/config/environment.dart';

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
  final ProfileRepository _repo = ProfileRepository();
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
    // Update server first, then refresh from server, then persist locally.
    String effectiveEmail = state.email.isNotEmpty ? state.email : newState.email;
    try {
      if (effectiveEmail.isNotEmpty) {
        // Map local fields to backend payload
        final apellidoParts = (newState.lastName).trim().split(RegExp(r"\s+"));
        final apellidoP = apellidoParts.isNotEmpty ? apellidoParts.first : '';
        final apellidoM = apellidoParts.length > 1
            ? apellidoParts.sublist(1).join(' ')
            : '';

        final payload = <String, dynamic>{
          'nombre': newState.fullName.trim(),
          'apellidoP': apellidoP,
          'apellidoM': apellidoM,
          // 'password': not updated here
          'numeroCuenta': newState.accountNumber.trim(),
          'nombreBanca': newState.bankName.trim(),
          'descripcion': (newState.address ?? '').trim(),
          'ci': newState.idNumber.trim(),
        }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

        await _repo.updateUserByEmail(effectiveEmail, payload);

        // Handle image upload or delete if changed
        final hadPhoto = (state.photoPath?.isNotEmpty ?? false);
        final hasNewPhoto = (newState.photoPath?.isNotEmpty ?? false);
        if (hasNewPhoto && newState.photoPath != state.photoPath) {
          final file = File(newState.photoPath!);
          if (await file.exists()) {
            await _repo.uploadProfileImageByEmail(effectiveEmail, file);
          }
        } else if (!hasNewPhoto && hadPhoto) {
          await _repo.deleteProfileImageByEmail(effectiveEmail);
        }

        // Refresh from server so local matches latest backend values
        await fetchRemoteProfile(effectiveEmail);
      }
    } catch (_) {
      // If server update fails, still update local so user sees their changes
      state = newState;
    }

    // Persist local state to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFullName, state.fullName);
    await prefs.setString(_kLastName, state.lastName);
    await prefs.setString(_kEmail, state.email.isNotEmpty ? state.email : effectiveEmail);
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

  Future<void> fetchRemoteProfile(String email) async {
    final raw = await _repo.getUserByEmail(email);
    final data = (raw['data'] is Map) ? (raw['data'] as Map) : raw;

      final nombre = (data['nombres'] ?? data['nombre'] ?? '').toString();
      final apellidoP = (data['apellidoP'] ?? '').toString();
      final apellidoM = (data['apellidoM'] ?? '').toString();
      final emailVal = (data['email'] ?? email).toString();
      final numeroCuenta = (data['numeroCuenta'] ?? '').toString();
      final nombreBanca = (data['nombreBanca'] ?? '').toString();
      final descripcion = (data['descripcion'] ?? '').toString();
      final ci = (data['ci'] ?? '').toString();
      final telefono = (data['telefono'] ?? '').toString();
      String imagen = (data['imagen'] ?? '').toString();
      if (imagen.isNotEmpty && !imagen.startsWith('http')) {
        final base = Environment.apiUrl.replaceAll(RegExp(r'/+$'), '');
        final rel = imagen.replaceFirst(RegExp(r'^/+'), '');
        imagen = '$base/$rel';
      }

    state = state.copyWith(
      fullName: nombre,
      lastName: [apellidoP, apellidoM].where((s) => s.trim().isNotEmpty).join(' ').trim(),
      email: emailVal,
      accountNumber: numeroCuenta,
      bankName: nombreBanca,
      address: descripcion.isEmpty ? null : descripcion,
      idNumber: ci,
      phoneNumber: telefono,
      photoPath: imagen,
    );

    // Persist basic fields locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFullName, state.fullName);
    await prefs.setString(_kLastName, state.lastName);
    await prefs.setString(_kEmail, state.email);
    await prefs.setString(_kIdNumber, state.idNumber);
    await prefs.setString(_kPhoneNumber, state.phoneNumber);
    if (state.photoPath == null || state.photoPath!.isEmpty) {
      await prefs.remove(_kPhotoPath);
    } else {
      await prefs.setString(_kPhotoPath, state.photoPath!);
    }
    await prefs.setString(_kAccountNumber, state.accountNumber);
    await prefs.setString(_kBankName, state.bankName);
    if (state.address == null || state.address!.isEmpty) {
      await prefs.remove(_kAddress);
    } else {
      await prefs.setString(_kAddress, state.address!);
    }
  }
}
