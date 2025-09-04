import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/profile/providers/profile_provider.dart';
import 'package:bombotickets/features/settings/providers/settings_provider.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerWidget {
  static String name = 'profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final authState = ref.watch(authProvider);
    final profile = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final bool reduce = settings.reduceMotion;

    final displayName =
        (profile.fullName.isNotEmpty
                ? profile.fullName
                : (authState.user?.username ?? 'Usuario'))
            .trim();

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppTheme.spacingLarge),

                  // Perfil card con estilo App/Glass
                  AppCard(
                    padding: EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: res.wp(12),
                              backgroundColor: AppTheme.primaryColor
                                  .withOpacity(0.12),
                              backgroundImage:
                                  profile.photoPath != null &&
                                      profile.photoPath!.isNotEmpty &&
                                      File(profile.photoPath!).existsSync()
                                  ? FileImage(File(profile.photoPath!))
                                  : null,
                              child:
                                  (profile.photoPath == null ||
                                      profile.photoPath!.isEmpty ||
                                      !File(profile.photoPath!).existsSync())
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: res.dp(6),
                                      color: AppTheme.primaryColor,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacingMedium),
                        AutoSizeText(
                          displayName,
                          style: GoogleFonts.poppins(
                            fontSize: AppTheme.fontSizeH3 - 2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          minFontSize: 14,
                        ),
                        if (profile.email.isNotEmpty) ...[
                          SizedBox(height: AppTheme.spacingSmall / 2),
                          AutoSizeText(
                            profile.email,
                            style: GoogleFonts.inter(
                              fontSize: AppTheme.fontSizeBodyNormal - 1,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 12,
                          ),
                        ],
                        SizedBox(height: AppTheme.spacingMedium),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showEditProfileSheet(context, ref),
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar Perfil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.spacingNormal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusSmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Datos del usuario
                  AppCard(
                    padding: EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(context, 'Mis Datos'),
                        SizedBox(height: AppTheme.spacingNormal),
                        _dataRow(
                          context,
                          'Nombre Completo',
                          profile.fullName.isNotEmpty ? profile.fullName : '—',
                        ),
                        _dataRow(
                          context,
                          'Apellidos',
                          profile.lastName.isNotEmpty ? profile.lastName : '—',
                        ),
                        _dataRow(
                          context,
                          'Email',
                          profile.email.isNotEmpty ? profile.email : '—',
                        ),
                        _dataRow(
                          context,
                          'Número de Celular',
                          profile.phoneNumber.isNotEmpty
                              ? profile.phoneNumber
                              : '—',
                        ),
                        _dataRow(
                          context,
                          'Carnet/NIT',
                          profile.idNumber.isNotEmpty ? profile.idNumber : '—',
                        ),
                        _dataRow(
                          context,
                          'Dirección',
                          profile.address?.isNotEmpty == true
                              ? profile.address!
                              : '—',
                        ),
                        _dataRow(
                          context,
                          'Número de Cuenta',
                          profile.accountNumber.isNotEmpty
                              ? profile.accountNumber
                              : '—',
                        ),
                        _dataRow(
                          context,
                          'Nombre del banco',
                          profile.bankName.isNotEmpty ? profile.bankName : '—',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Tema de la app + accesibilidad
                  AppCard(
                    padding: EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(context, 'Tema de la app'),
                        const SizedBox(height: 8),
                        RadioListTile<ThemeMode>(
                          title: const Text('Automático'),
                          subtitle: const Text('Usa el tema del dispositivo'),
                          value: ThemeMode.system,
                          groupValue: settings.themeMode,
                          onChanged: (m) => ref
                              .read(settingsProvider.notifier)
                              .setThemeMode(m!),
                          dense: true,
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Claro'),
                          value: ThemeMode.light,
                          groupValue: settings.themeMode,
                          onChanged: (m) => ref
                              .read(settingsProvider.notifier)
                              .setThemeMode(m!),
                          dense: true,
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Oscuro'),
                          value: ThemeMode.dark,
                          groupValue: settings.themeMode,
                          onChanged: (m) => ref
                              .read(settingsProvider.notifier)
                              .setThemeMode(m!),
                          dense: true,
                        ),
                        const Divider(height: 24),
                        _sectionTitle(context, 'Accesibilidad'),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reducir animaciones'),
                          subtitle: const Text(
                            'Oculta transiciones y efectos para mayor fluidez',
                          ),
                          value: reduce,
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setReduceMotion(v),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Acciones: Ayuda, Acerca y Cerrar sesión
                  InfoGlassCard(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: 'Ayuda',
                    subtitle: 'Centro de soporte',
                    onTap: () {},
                    accentColor: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 12),
                  InfoGlassCard(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: 'Acerca de',
                    subtitle: 'Versión y créditos',
                    onTap: () {},
                    accentColor: AppTheme.warningColor,
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Logout
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final shouldLogout = await _showLogoutDialog(context);
                          if (shouldLogout == true) {
                            ref.read(authProvider.notifier).logout();
                            if (context.mounted) context.go('/');
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spacingNormal),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Colors.red,
                                size: res.dp(2.5),
                              ),
                              SizedBox(width: AppTheme.spacingMedium),
                              Expanded(
                                child: AutoSizeText(
                                  'Cerrar Sesión',
                                  style: GoogleFonts.poppins(
                                    fontSize: AppTheme.fontSizeBodyLarge,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.red.withOpacity(0.6),
                                size: res.dp(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

<<<<<<<<< Temporary merge branch 1
                SizedBox(height: AppTheme.spacingLarge),

                // Logout Button Simple
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Cerrar Sesión',
                  onTap: () async {
                    final shouldLogout = await _showLogoutDialog(context);
                    if (shouldLogout == true) {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/splash');
                      }
                    }
                  },
                  res: res,
                  isLogout: true,
                ),

                SizedBox(height: AppTheme.spacingLarge),
              ],
=========
                  SizedBox(height: AppTheme.spacingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
        fontSize: AppTheme.fontSizeBodyLarge,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      maxLines: 1,
    );
  }

  Widget _dataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal - 1,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: AppTheme.fontSizeBodyLarge - 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Responsive res,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
          border: Border.all(
            color: isLogout
                ? Colors.red.withOpacity(0.3)
                : Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : Theme.of(context).iconTheme.color,
              size: res.dp(2.5),
            ),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyNormal,
                  fontWeight: FontWeight.w500,
                  color: isLogout
                      ? Colors.red
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: res.dp(1.8),
              color: isLogout
                  ? Colors.red.withOpacity(0.7)
                  : Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeH3,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.inter(fontSize: AppTheme.fontSizeBodyNormal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: AppTheme.grey1,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final profile = ref.read(profileProvider);

    final fullNameCtrl = TextEditingController(text: profile.fullName);
    final lastNameCtrl = TextEditingController(text: profile.lastName);
    final emailCtrl = TextEditingController(text: profile.email);
    final phoneCtrl = TextEditingController(text: profile.phoneNumber);
    final idCtrl = TextEditingController(text: profile.idNumber);
    final addressCtrl = TextEditingController(text: profile.address ?? '');
    final accountCtrl = TextEditingController(text: profile.accountNumber);
    final bankCtrl = TextEditingController(text: profile.bankName);

    String? tempPhoto = profile.photoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bool hasTempPhoto =
                (tempPhoto?.isNotEmpty ?? false) &&
                File(tempPhoto!).existsSync();
            final ImageProvider? tempPhotoImage = hasTempPhoto
                ? FileImage(File(tempPhoto!))
                : null;
            return Container(
              padding: EdgeInsets.only(
                left: res.wp(6),
                right: res.wp(6),
                top: res.hp(1.5),
                bottom: MediaQuery.of(context).viewInsets.bottom + res.hp(2),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(res.wp(6)),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: res.wp(12),
                        height: res.hp(0.5),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(res.wp(2)),
                        ),
                      ),
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'Editar Perfil',
                      style: GoogleFonts.poppins(
                        fontSize: AppTheme.fontSizeH3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: res.hp(2)),

                    // Foto de perfil con acción
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: res.wp(12),
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.12,
                            ),
                            backgroundImage: tempPhotoImage,
                            child: (!hasTempPhoto)
                                ? Icon(
                                    Icons.person_rounded,
                                    size: res.dp(6),
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showImageSourceSheet(
                                context,
                                onPick: (path) {
                                  setState(() => tempPhoto = path);
                                },
                                onDelete: () {
                                  setState(() => tempPhoto = null);
                                },
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: res.hp(2)),

                    _inputField(
                      'Nombre Completo',
                      fullNameCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Apellidos',
                      lastNameCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Email',
                      emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Número de Celular',
                      phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Carnet/NIT',
                      idCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Dirección (Opcional)',
                      addressCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Número de Cuenta',
                      accountCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    _inputField(
                      'Nombre del banco',
                      bankCtrl,
                      textInputAction: TextInputAction.done,
                    ),

                    SizedBox(height: res.hp(2)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        SizedBox(width: res.wp(3)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(profileProvider.notifier)
                                  .updateProfile(
                                    ProfileState(
                                      fullName: fullNameCtrl.text.trim(),
                                      lastName: lastNameCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      phoneNumber: phoneCtrl.text.trim(),
                                      idNumber: idCtrl.text.trim(),
                                      address: addressCtrl.text.trim().isEmpty
                                          ? null
                                          : addressCtrl.text.trim(),
                                      accountNumber: accountCtrl.text.trim(),
                                      bankName: bankCtrl.text.trim(),
                                      photoPath: tempPhoto,
                                    ),
                                  );
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Guardar cambios'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingNormal),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(
    BuildContext context, {
    required void Function(String? path) onPick,
    required VoidCallback onDelete,
  }) {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.borderRadiusLarge),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Cámara'),
                  onTap: () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    Navigator.pop(context);
                    onPick(image?.path);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    Navigator.pop(context);
                    onPick(image?.path);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Eliminar Foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
