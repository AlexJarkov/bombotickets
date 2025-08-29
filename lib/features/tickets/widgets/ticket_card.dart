import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import '../entities/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onShowQr;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: res.hp(2)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: res.wp(2),
            offset: Offset(0, res.hp(0.2)),
          ),
        ],
        border: Border.all(color: AppTheme.navBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen del evento
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.borderRadiusNormal),
              bottomLeft: Radius.circular(AppTheme.borderRadiusNormal),
            ),
            child: Image.asset(
              'assets/images/bombo.png',
              width: res.wp(28),
              height: res.hp(16),
              fit: BoxFit.cover,
              // Si no existe bombo.png, hacemos fallback al asset del ticket
              errorBuilder: (_, __, ___) => Image.asset(
                ticket.imageAsset,
                width: res.wp(28),
                height: res.hp(16),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(res.wp(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventName,
                        style: TextStyle(
                          fontSize: res.dp(2.0),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.bodyFontColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: res.hp(0.8)),
                      _StatusChip(status: ticket.status),
                    ],
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.highlightBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: res.hp(1),
                          horizontal: res.wp(3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                      ),
                      onPressed: onShowQr,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Mostrar ticket'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TicketStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
