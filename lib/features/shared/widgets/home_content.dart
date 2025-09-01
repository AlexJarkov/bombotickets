import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/shared/widgets/app_toast.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeContent extends StatelessWidget {
  final Function(int) onItemTapped;

  const HomeContent({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF0B1E3B), // deep navy
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kBottomNavigationBarHeight,
            ),
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
                  AppCard(
                    animationDelay: 200.ms,
                    child: Column(
                      children: [
                        Icon(
                          Icons.confirmation_number,
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
                          'Compra, vende y gestiona tickets de eventos',
                          style: TextStyle(
                            fontSize: res.dp(1.8),
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: res.hp(4)),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionAppCard(
                          icon: Icons.add_shopping_cart,
                          title: 'Comprar',
                          subtitle: 'Buscar eventos',
                          color: Colors.green,
                          animationDelay: 400.ms,
                          onTap: () {
                            AppToast.showInfo(
                              context,
                              title: 'Próximamente',
                              description:
                                  'La función de compra estará disponible pronto',
                            );
                            onItemTapped(1);
                          },
                        ),
                      ),
                      SizedBox(width: res.wp(4)),
                      Expanded(
                        child: QuickActionAppCard(
                          icon: Icons.sell,
                          title: 'Vender',
                          subtitle: 'Tus tickets',
                          color: Colors.orange,
                          animationDelay: 500.ms,
                          onTap: () => onItemTapped(1),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: res.hp(3)),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionAppCard(
                          icon: Icons.qr_code_scanner,
                          title: 'Escanear',
                          subtitle: 'Validar ticket',
                          color: Colors.blue,
                          animationDelay: 600.ms,
                          onTap: () => onItemTapped(2),
                        ),
                      ),
                      SizedBox(width: res.wp(4)),
                      Expanded(
                        child: QuickActionAppCard(
                          icon: Icons.event,
                          title: 'Mis Eventos',
                          subtitle: 'Ver historial',
                          color: Colors.purple,
                          animationDelay: 700.ms,
                          onTap: () => onItemTapped(3),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: res.hp(6)), // Espacio final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
