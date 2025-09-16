import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart' as ptr;
import '../entities/ticket.dart';
import '../providers/marketplace_provider.dart';
import 'create_marketplace_listing_screen.dart';

// Provider para filtro de estado
final selectedSalesStatusProvider = StateProvider<OfferStatus?>((ref) => null);

// Provider para mis ventas filtradas
final mySalesProvider = FutureProvider<List<MarketplaceOffer>>((ref) async {
  final ticketsRepository = ref.watch(ticketsRepositoryProvider);
  return ticketsRepository.getMyMarketplaceOffers();
});

class MySalesScreen extends ConsumerStatefulWidget {
  const MySalesScreen({super.key});

  @override
  ConsumerState<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends ConsumerState<MySalesScreen> {
  late ptr.RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = ptr.RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      // Invalidar el provider para recargar los datos
      ref.invalidate(mySalesProvider);

      // Esperar a que el provider termine de cargar
      await ref.read(mySalesProvider.future);

      // Completar el refresh
      _refreshController.refreshCompleted();

      // Mostrar mensaje de éxito (opcional)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ventas actualizadas'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Si hay error, mostrar que falló el refresh
      _refreshController.refreshFailed();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al actualizar ventas'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);
    final salesAsync = ref.watch(mySalesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo animado
          const AnimatedBackground(child: SizedBox.expand()),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(res, theme, context),

                // Botón Nueva Venta
                _buildNewSaleButton(res, theme, context),

                // Tabs de estado
                _buildStatusTabs(res, theme, ref),

                // Lista de ventas
                Expanded(child: _buildSalesList(res, theme, salesAsync, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive res, ThemeData theme, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.colorScheme.onSurface,
              size: res.dp(2.5),
            ),
          ),
          SizedBox(width: res.wp(2)),
          Expanded(
            child: Text(
              'Mis Ventas',
              style: GoogleFonts.poppins(
                fontSize: AppTheme.fontSizeH2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewSaleButton(
    Responsive res,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: res.wp(4),
        vertical: res.hp(0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _navigateToCreateListing(context),
              icon: Icon(
                Icons.add,
                color: AppTheme.primaryColor,
                size: res.dp(2.2),
              ),
              label: Text(
                'Nueva Venta',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                  fontSize: res.dp(1.6),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: res.hp(1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(Responsive res, ThemeData theme, WidgetRef ref) {
    final selectedStatus = ref.watch(selectedSalesStatusProvider);

    return Container(
      height: res.hp(6),
      margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: res.wp(4)),
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatusTab('Todas', null, selectedStatus, ref, res),
          _buildStatusTab(
            'Publicadas',
            OfferStatus.publicada,
            selectedStatus,
            ref,
            res,
          ),
          _buildStatusTab(
            'Vendidas',
            OfferStatus.vendida,
            selectedStatus,
            ref,
            res,
          ),
          _buildStatusTab(
            'Canceladas',
            OfferStatus.cancelada,
            selectedStatus,
            ref,
            res,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(
    String label,
    OfferStatus? status,
    OfferStatus? selectedStatus,
    WidgetRef ref,
    Responsive res,
  ) {
    final isSelected = selectedStatus == status;

    return Container(
      margin: EdgeInsets.only(right: res.wp(2)),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(selectedSalesStatusProvider.notifier).state = selected
              ? status
              : null;
        },
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.grey1,
          fontWeight: FontWeight.w600,
          fontSize: AppTheme.fontSizeBodyNormal,
        ),
      ),
    );
  }

  Widget _buildSalesList(
    Responsive res,
    ThemeData theme,
    AsyncValue<List<MarketplaceOffer>> salesAsync,
    WidgetRef ref,
  ) {
    return salesAsync.when(
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
              'Error al cargar ventas',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyLarge,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      data: (sales) {
        if (sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: res.dp(8),
                  color: AppTheme.grey1,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  'No tienes ventas aún',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Crea tu primera oferta para comenzar a vender',
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

        return ptr.SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: false,
          header: ptr.MaterialClassicHeader(
            backgroundColor: theme.scaffoldBackgroundColor,
            color: AppTheme.primaryColor,
            distance: 80, // Aumentado de 50 a 80 para ser menos sensible
          ),
          onRefresh: _onRefresh,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: res.wp(4)),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];

              return Container(
                    margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                    child: _buildSaleCard(sale, res, theme),
                  )
                  .animate(delay: Duration(milliseconds: index * 100))
                  .fadeIn(duration: 600.ms)
                  .slideX(
                    begin: 0.3,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  );
            },
          ),
        );
      },
    );
  }

  Widget _buildSaleCard(
    MarketplaceOffer sale,
    Responsive res,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con imagen y título del evento
          Container(
            padding: EdgeInsets.all(AppTheme.spacingNormal),
            child: Row(
              children: [
                // Imagen del evento
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  child: Container(
                    width: res.wp(15),
                    height: res.wp(15),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.event,
                      color: AppTheme.primaryColor,
                      size: res.dp(3),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacingNormal),

                // Información del evento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.ticketOfertado.evento.nombre,
                        style: GoogleFonts.poppins(
                          fontSize: AppTheme.fontSizeH3,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppTheme.spacingSmall / 2),
                      Text(
                        'Zona: ${sale.ticketOfertado.zona.nombre}',
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          color: AppTheme.grey1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado de la oferta
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: res.wp(2),
                    vertical: res.hp(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      sale.statusOferta,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                    border: Border.all(
                      color: _getStatusColor(
                        sale.statusOferta,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(sale.statusOferta),
                    style: GoogleFonts.inter(
                      fontSize: AppTheme.fontSizeBodyNormal,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(sale.statusOferta),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información de precio y zona
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingNormal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio ofertado',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                    ),
                    Text(
                      '\$${sale.precioOfertado.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: AppTheme.fontSizeH3,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Zona',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                    ),
                    Text(
                      sale.ticketOfertado.zona.nombre,
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.spacingNormal),

          // Información adicional y acciones
          Container(
            padding: EdgeInsets.all(AppTheme.spacingNormal),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.borderRadiusNormal),
                bottomRight: Radius.circular(AppTheme.borderRadiusNormal),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Publicado: ${_formatDate(sale.fechaOferta)}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                    ),
                    if (sale.fechaRespuesta != null)
                      Text(
                        'Vendido: ${_formatDate(sale.fechaRespuesta!)}',
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          color: AppTheme.successColor,
                        ),
                      ),
                  ],
                ),

                if (sale.isActive) ...[
                  SizedBox(height: AppTheme.spacingNormal),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editOffer(sale),
                          icon: Icon(Icons.edit, size: res.dp(2)),
                          label: Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingNormal),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelOffer(sale),
                          icon: Icon(Icons.cancel, size: res.dp(2)),
                          label: Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: BorderSide(color: AppTheme.errorColor),
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.publicada:
        return AppTheme.primaryColor;
      case OfferStatus.vendida:
        return AppTheme.successColor;
      case OfferStatus.cancelada:
        return AppTheme.errorColor;
    }
  }

  String _getStatusLabel(OfferStatus status) {
    switch (status) {
      case OfferStatus.publicada:
        return 'Publicada';
      case OfferStatus.vendida:
        return 'Vendida';
      case OfferStatus.cancelada:
        return 'Cancelada';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editOffer(MarketplaceOffer offer) {
    // Implementar edición de oferta
  }

  void _cancelOffer(MarketplaceOffer offer) {
    // Implementar cancelación de oferta
  }

  void _navigateToCreateListing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateMarketplaceListingScreen(),
      ),
    );
  }
}
