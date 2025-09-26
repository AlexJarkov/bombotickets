import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/ticket.dart';

/// Proveedor simple que retorna tickets hardcodeados para demostración.
final ticketsProvider = Provider<List<Ticket>>((ref) {
  return const [
    Ticket(
      id: 'TCKT-001',
      eventName: 'Concierto Bombo Fest 2024',
      imageAsset: 'assets/images/qr.png',
      status: TicketStatus.activo,
      // Para demo, usamos una imagen QR local incluida en assets
      qrAsset: 'assets/images/qr.png',
      // Cuando se conecte a la API, se podrá usar qrData para generar QR
      qrData: 'BOMBO_TICKET_TCKT-001',
    ),
  ];
});
