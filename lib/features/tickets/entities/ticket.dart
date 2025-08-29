import 'package:flutter/material.dart';

enum TicketStatus { activo, usado, vendido }

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.activo:
        return 'Activo';
      case TicketStatus.usado:
        return 'Usado';
      case TicketStatus.vendido:
        return 'Vendido';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.activo:
        return Colors.green;
      case TicketStatus.usado:
        return Colors.grey;
      case TicketStatus.vendido:
        return Colors.orange;
    }
  }
}

class Ticket {
  final String id;
  final String eventName;
  final String imageAsset;
  final TicketStatus status;
  final String? qrAsset; // imagen QR local para demo
  final String? qrData; // futuro: dato para generar QR

  const Ticket({
    required this.id,
    required this.eventName,
    required this.imageAsset,
    required this.status,
    this.qrAsset,
    this.qrData,
  });
}

