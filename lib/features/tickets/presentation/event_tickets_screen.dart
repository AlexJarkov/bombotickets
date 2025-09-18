import 'package:bombotickets/features/tickets/qr/presentation/qr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import '../entities/ticket.dart';
import '../providers/marketplace_provider.dart';
import '../providers/filters_provider.dart';
import 'package:collection/collection.dart';
import 'dart:developer';

class EventTicketsScreen extends ConsumerStatefulWidget {
  final String eventName;

  const EventTicketsScreen({super.key, required this.eventName});

  @override
  ConsumerState<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends ConsumerState<EventTicketsScreen> {
  @override
  void initState() {
    super.initState();
    // Reset zone filter when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedZoneProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.eventName,
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeH2,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Zone Filter Chips
              _buildZoneFilters(res, theme),

              // Tickets List
              Expanded(child: _buildTicketsList(res, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneFilters(Responsive res, ThemeData theme) {
    final zonesAsync = ref.watch(zonesProvider);
    final selectedZone = ref.watch(selectedZoneProvider);

    return zonesAsync.when(
      loading: () => const SizedBox(height: 60),
      error: (error, stack) => const SizedBox(height: 60),
      data: (zones) {
        // Filter zones that belong to this event
        final eventZones = zones
            .where((zone) => zone.evento.nombre == widget.eventName)
            .toList();

        if (eventZones.isEmpty) {
          return const SizedBox(height: 60);
        }

        return Container(
          height: 60,
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: res.wp(4)),
            itemCount: eventZones.length + 1, // +1 for "Todas" chip
            itemBuilder: (context, index) {
              if (index == 0) {
                // "Todas" chip
                return _buildZoneChip(
                  res,
                  theme,
                  'Todas',
                  selectedZone == null,
                  () => ref.read(selectedZoneProvider.notifier).state = null,
                );
              }

              final zone = eventZones[index - 1];
              return _buildZoneChip(
                res,
                theme,
                zone.nombre,
                selectedZone?.zonaId == zone.zonaId,
                () => ref.read(selectedZoneProvider.notifier).state = zone,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildZoneChip(
    Responsive res,
    ThemeData theme,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: AppTheme.spacingSmall),
        padding: EdgeInsets.symmetric(
          horizontal: res.wp(4),
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.grey1.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppTheme.fontSizeBodyNormal,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsList(Responsive res, ThemeData theme) {
    final filteredTicketsAsync = ref.watch(
      filteredEventTicketsProvider(widget.eventName),
    );

    return filteredTicketsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: res.dp(6), color: Colors.red),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Error al cargar tickets',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyLarge,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              error.toString(),
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: AppTheme.grey1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (offers) {
        if (offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_num_outlined, size: res.dp(8), color: AppTheme.grey1),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  'No hay tickets disponibles',
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'No se encontraron tickets para este evento',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: AppTheme.grey1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Agrupa directamente por ID de publicación, contando duplicados como múltiples tickets
        int pubKey(MarketplaceOffer o) => o.id;
        final groups = groupBy<MarketplaceOffer, int>(offers, (o) => pubKey(o));
        groups.forEach((k, v) => log('pubId=$k -> ${v.length} disponibles'));

        // Construye una lista de items únicos con su cantidad de tickets disponibles
        final grouped = groups.entries.map((e) => (
          offer: e.value.first,              // datos para mostrar (usa el primero, ya que son idénticos)
          disponibles: e.value.length,       // cantidad de tickets (incluyendo duplicados)
        )).toList();

        // Renderiza una sola card por publicación
        return ListView.builder(
          padding: EdgeInsets.all(res.wp(4)),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final item = grouped[index];
            return _buildOfferCard(item.offer, item.disponibles, res, theme)
                .animate(delay: Duration(milliseconds: index * 100))
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, duration: 400.ms);
          },
        );
      },
    );
  }

  Widget _buildOfferCard(
    MarketplaceOffer offer,
    int disponibles,
    Responsive res,
    ThemeData theme,
  ) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      animated: true,
      animationDuration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFO DEL TICKET
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zona
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingSmall / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        offer.ticketOfertado.zona.nombre,
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),

                    // Lugar - Ciudad
                    Text(
                      '${offer.ticketOfertado.evento.lugar} - ${offer.ticketOfertado.evento.ciudad}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall / 2),

                    // Fecha
                    Text(
                      'Fecha: ${offer.ticketOfertado.evento.fecha}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),

                    // Vendedor
                    Text(
                      'Vendedor: ${offer.userOfertante.nombres} ${offer.userOfertante.apellidoP}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),

                    // DISPONIBLES
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingSmall / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        'Disponibles: $disponibles',
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: AppTheme.spacingNormal),

              // PRECIO + BOTÓN
              Column(
                children: [
                  Text(
                    'Bs. ${offer.precioOfertado.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeH3,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        QrScreen.name,
                        extra: {
                          'unitPrice': offer.precioOfertado,
                          'maxQuantity': disponibles,
                          'publicationId': offer.id,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: res.wp(4),
                        vertical: AppTheme.spacingSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                    ),
                    child: Text(
                      'Comprar',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          // STATUS
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: AppTheme.spacingSmall / 2,
            ),
            decoration: BoxDecoration(
              color: _getOfferStatusColor(offer.statusOferta).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getOfferStatusIcon(offer.statusOferta),
                  size: res.dp(1.6),
                  color: _getOfferStatusColor(offer.statusOferta),
                ),
                const SizedBox(width: 4),
                Text(
                  _getOfferStatusText(offer.statusOferta),
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    fontWeight: FontWeight.w600,
                    color: _getOfferStatusColor(offer.statusOferta),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for offer status
  Color _getOfferStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.publicada:
        return Colors.green;
      case OfferStatus.vendida:
        return Colors.blue;
      case OfferStatus.cancelada:
        return Colors.red;
    }
  }

  IconData _getOfferStatusIcon(OfferStatus status) {
    switch (status) {
      case OfferStatus.publicada:
        return Icons.storefront;
      case OfferStatus.vendida:
        return Icons.check_circle;
      case OfferStatus.cancelada:
        return Icons.cancel;
    }
  }

  String _getOfferStatusText(OfferStatus status) {
    switch (status) {
      case OfferStatus.publicada:
        return 'Disponible';
      case OfferStatus.vendida:
        return 'Vendido';
      case OfferStatus.cancelada:
        return 'Cancelado';
    }
  }
}