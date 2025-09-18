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
                    'Haz finalizado',
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

              Text(
                    'Monto pendiente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                  .slideY(
                    begin: 0.2,
                    duration: 600.ms,
                    curve: Curves.easeOutQuart,
                  ),

              SizedBox(height: 16),

              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      //padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      height: 72,
                      //margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        //color: Colors.red[100],
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Text(
                        "Bs. 0",
                        //'${qrForm.currentAmount}',
                        style: TextStyle(
                          //color:Colors.green[800],
                          color: Colors.green,
                          fontSize: AppTheme.fontSizeBodyLarge,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                  .slideY(
                    begin: 0.3,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .then(delay: 300.ms)
                  .shimmer(
                    duration: 1500.ms,
                    color: Colors.green.withOpacity(0.5),
                  ),

              SizedBox(height: 40),

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
                        color: Colors.green.withOpacity(0.4),
                      )
                      .animate(delay: 1200.ms)
                      .shake(duration: 800.ms, hz: 1),

                  const SizedBox(height: 16),

                  Text(
                        '¡Mesa cobrada exitosamente!',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeBodyLarge,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate(delay: 1100.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then(delay: 300.ms)
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.green.withOpacity(0.3),
                      ),
                ],
              ),

              const SizedBox(height: 24),

              // Botones de acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/exito-share-btn-icon.svg',
                          //width: 48,
                          semanticsLabel: 'Share Button',
                        ),
                        onPressed: () {
                          // Lógica para compartir
                        },
                      )
                      .animate(delay: 1600.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(
                        begin: -0.5,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .animate(target: 1)
                      .scale(
                        duration: 100.ms,
                        curve: Curves.easeOut,
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(0.95, 0.95),
                      ),
                  const SizedBox(width: 24),
                  IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/exito-download-btn-icon.svg',
                          //width: 48,
                          semanticsLabel: 'Download Button',
                        ),
                        onPressed: () {
                          // Lógica para descargar comprobante
                        },
                      )
                      .animate(delay: 1700.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(
                        begin: 0.5,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .animate(target: 1)
                      .scale(
                        duration: 100.ms,
                        curve: Curves.easeOut,
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(0.95, 0.95),
                      ),
                ],
              ),

              const SizedBox(height: 40),

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
        ),
      ),
    );
  }
}
