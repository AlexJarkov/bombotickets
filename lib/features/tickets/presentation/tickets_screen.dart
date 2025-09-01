import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import '../entities/ticket.dart';
import '../widgets/event_tickets_group.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    // Tickets hardcodeados para demo
    const tickets = [
      Ticket(
        id: 'TCKT-001',
        eventName: 'Concierto Bombo Fest 2024',
        imageAsset: 'assets/images/banner_bombo.png',
        status: TicketStatus.activo,
        qrAsset: 'assets/images/qr.png',
        qrData: 'BOMBO_TICKET_TCKT-001',
      ),
      Ticket(
        id: 'TCKT-002',
        eventName: 'Concierto Bombo Fest 2024',
        imageAsset: 'assets/images/banner_bombo.png',
        status: TicketStatus.activo,
        qrAsset: 'assets/images/qr.png',
        qrData: 'BOMBO_TICKET_TCKT-002',
      ),
      Ticket(
        id: 'TCKT-003',
        eventName: 'Concierto Bombo Fest 2024',
        imageAsset: 'assets/images/banner_bombo.png',
        status: TicketStatus.usado,
        qrAsset: 'assets/images/qr.png',
        qrData: 'BOMBO_TICKET_TCKT-003',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Tickets',
                style: TextStyle(
                  fontSize: res.dp(2.5),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: res.hp(2.5)),

              Expanded(
                child: Container(
                  padding: EdgeInsets.all(res.wp(4)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(res.wp(5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: res.wp(2.5),
                        spreadRadius: res.wp(0.5),
                      ),
                    ],
                  ),
                  child: _GroupedTickets(
                    tickets: tickets,
                    onShowQr: (t) => _showQr(context, t),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQr(BuildContext context, Ticket ticket) {
    final res = Responsive.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(res.wp(6)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(res.wp(6)),
            topRight: Radius.circular(res.wp(6)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: res.wp(12),
              height: res.hp(0.5),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(res.wp(2)),
              ),
            ),
            SizedBox(height: res.hp(2)),
            Text(
              ticket.eventName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: res.dp(2.2),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: res.hp(2)),

            // Para demo: mostramos imagen de QR local. Si se provee qrData,
            // se puede reemplazar por un generador de QR (p.ej. qr_flutter).
            if (ticket.qrAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(res.wp(2)),
                child: Image.asset(
                  ticket.qrAsset!,
                  width: res.wp(60),
                  height: res.wp(60),
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                width: res.wp(60),
                height: res.wp(60),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(res.wp(2)),
                ),
                child: const Text('QR no disponible'),
              ),

            SizedBox(height: res.hp(2)),
            Text(
              'Muestra este QR al ingresar al evento',
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
                fontSize: res.dp(1.6),
              ),
            ),
            SizedBox(height: res.hp(2.5)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.highlightBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: res.hp(1.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedTickets extends StatelessWidget {
  final List<Ticket> tickets;
  final void Function(Ticket) onShowQr;

  const _GroupedTickets({required this.tickets, required this.onShowQr});

  @override
  Widget build(BuildContext context) {
    // Agrupar tickets por evento (clave: nombre del evento)
    final Map<String, List<Ticket>> groups = {};
    for (final t in tickets) {
      groups.putIfAbsent(t.eventName, () => []).add(t);
    }

    return ListView(
      children: groups.entries.map((entry) {
        final eventName = entry.key;
        final list = entry.value;
        final image = list.first.imageAsset;

        return EventTicketsGroup(
          eventName: eventName,
          imageAsset: image,
          tickets: list,
          onShowQr: onShowQr,
        );
      }).toList(),
    );
  }
}

// Estado vacío eliminado porque el card está hardcodeado en esta pantalla.
