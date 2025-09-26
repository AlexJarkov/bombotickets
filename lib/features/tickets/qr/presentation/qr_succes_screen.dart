import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/tickets/qr/providers/qr_form_provider.dart';
import 'package:bombotickets/features/tickets/qr/providers/qr_payment_process_provider.dart';
import 'package:bombotickets/features/shared/widgets/custom_button.dart';

class QrSuccessScreen extends ConsumerWidget {
  static const name = 'qr-success';

  const QrSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final qrForm = ref.watch(qrFormProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                    'Haz finalizado, tus entradas te llegaran a tu correo ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                  .slideY(
                    begin: -0.3,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

              SizedBox(height: 24),

              // Icono de check y mensaje
              Column(
                children: [
                  SvgPicture.asset(
                        'assets/icons/big-check-icon.svg',
                        //width: 130,
                        semanticsLabel: 'Check Icon',
                      )
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 800.ms, curve: Curves.easeOutQuart)
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        duration: 1000.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then(delay: 500.ms)
                      .shimmer(
                        duration: 2000.ms,
                        color: AppTheme.primaryColor.withOpacity(0.4),
                      )
                      .animate(delay: 1200.ms)
                      .shake(duration: 800.ms, hz: 1),

                  const SizedBox(height: 16),
              // Botón de finalizar
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CustomButton(
                      text: 'Finalizar',
                      onPressed: () {
                        ref.read(qrFormProvider.notifier).reset();
                        ref.read(qrPaymentProcessProvider.notifier).reset();
                        context.go('/home');
                      },
                    ),
                  )
                  .animate(delay: 1900.ms)
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                  .slideY(
                    begin: 0.5,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
            ],
          ),
        ]),
      ),
    ));
  }
}
