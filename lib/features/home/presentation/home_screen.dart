import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static String name = 'home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF0B1E3B),
                  Color(0xFF091A32),
                  Colors.transparent,
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(res.wp(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: res.hp(2)),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo_masterpass.png',
                  width: res.wp(50),
                  fit: BoxFit.contain,
                  color: isDark ? Colors.white : Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),

              SizedBox(height: res.hp(4)),

              // Welcome Card
              Container(
                padding: EdgeInsets.all(res.wp(6)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(res.wp(5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: res.wp(2.5),
                      spreadRadius: res.wp(0.5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.home,
                      size: res.dp(6),
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'Bienvenido a Bombotickets',
                      style: TextStyle(
                        fontSize: res.dp(2.5),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'Gestiona tus tickets de manera fácil y eficiente',
                      style: TextStyle(
                        fontSize: res.dp(1.8),
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
