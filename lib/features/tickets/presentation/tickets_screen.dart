import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:bombotickets/features/shared/widgets/glass_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:motion_toast/motion_toast.dart';
import '../entities/ticket.dart';

// Provider para manejar el estado de la pantalla de tickets
final ticketsTabProvider = StateProvider<int>((ref) => 0);

// Datos de ejemplo para eventos disponibles
final availableEventsProvider = Provider<List<EventTicket>>(
  (ref) => [
    EventTicket(
      id: 'EVENT-001',
      title: 'Bombo Fest 2024',
      artist: 'Various Artists',
      venue: 'Estadio Nacional',
      date: DateTime(2024, 12, 15, 20, 0),
      price: 50000,
      originalPrice: 60000,
      imageUrl: 'https://picsum.photos/400/300?random=1',
      category: 'Música',
      availableTickets: 15,
      isResale: false,
    ),
    EventTicket(
      id: 'EVENT-002',
      title: 'Noche de Stand Up',
      artist: 'Comediantes Varios',
      venue: 'Teatro Municipal',
      date: DateTime(2024, 11, 20, 21, 0),
      price: 25000,
      originalPrice: 25000,
      imageUrl: 'https://picsum.photos/400/300?random=2',
      category: 'Comedia',
      availableTickets: 8,
      isResale: false,
    ),
    EventTicket(
      id: 'EVENT-003',
      title: 'Festival Electrónico',
      artist: 'DJ Snake ft. Martin Garrix',
      venue: 'Club Blondie',
      date: DateTime(2024, 11, 30, 23, 0),
      price: 45000,
      originalPrice: 50000,
      imageUrl: 'https://picsum.photos/400/300?random=3',
      category: 'Electrónica',
      availableTickets: 3,
      isResale: true,
    ),
  ],
);

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Lee el tab inicial desde el provider (por si Home preselecciona Vender)
    final initialIndex = ref.read(ticketsTabProvider);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex.clamp(0, 1), // Solo 2 tabs ahora
    );
    _tabController.addListener(() {
      ref.read(ticketsTabProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);
    final reduce = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: () {
        // Quitar focus al tocar fuera del input
        FocusScope.of(context).unfocus();
      },
      child: AnimatedBackground(
        style: BackgroundStyle.surface,
        animated: !reduce,
        intensity: 0.6,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Header moderno sin AppBar
              Padding(
                padding: EdgeInsets.only(
                  top: AppTheme.spacingLarge,
                  left: AppTheme.spacingMedium,
                  right: AppTheme.spacingMedium,
                  bottom: AppTheme.spacingMedium,
                ),
                child: SizedBox.shrink(),
              ),

              // Tabs con diseño original (indicador debajo, todo el ancho)
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                ),
                child: (() {
                      final w = TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          isScrollable: false,
                          labelPadding: EdgeInsets.zero,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 3,
                            ),
                            insets: EdgeInsets.zero,
                          ),
                          labelColor: AppTheme.primaryColor,
                          unselectedLabelColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: [
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_cart, size: 16),
                                    SizedBox(width: 4),
                                    Text('Comprar'),
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sell, size: 16),
                                    SizedBox(width: 4),
                                    Text('Vender'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      if (reduce) return w;
                      return w
                          .animate()
                          .slideY(duration: 260.ms, begin: 0.16, end: 0)
                          .fadeIn(duration: 260.ms);
                    })(),
              ),

              // Contenido de tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBuyTab(res, theme),
                    _buildSellTab(res, theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab de compra de tickets
  Widget _buildBuyTab(Responsive res, ThemeData theme) {
    final availableEvents = ref.watch(availableEventsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(res.wp(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda y filtros para compras
          Row(
            children: [
              Expanded(
                child: (() {
                      final w = GlassSearchBar(
                          controller: _searchController,
                          hintText: 'Buscar eventos, artistas...',
                          iconSize: res.dp(2.2),
                          onChanged: (value) {
                            // TODO: Implementar búsqueda
                          },
                        );
                      if (MediaQuery.of(context).disableAnimations) return w;
                      return w
                          .animate()
                          .slideX(duration: 280.ms, begin: 0.14, end: 0)
                          .fadeIn(duration: 280.ms);
                    })(),
              ),

              SizedBox(width: AppTheme.spacingSmall),

              GlassCard(
                padding: EdgeInsets.all(AppTheme.spacingSmall),
                borderRadius: AppTheme.borderRadiusSmall,
                child: InkWell(
                  onTap: () => _showFilterBottomSheet(context),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppTheme.primaryColor,
                    size: res.dp(2.4),
                  ),
                ),
              ).animate(target: MediaQuery.of(context).disableAnimations ? 1 : 1).scale(duration: MediaQuery.of(context).disableAnimations ? 1.ms : 240.ms, delay: MediaQuery.of(context).disableAnimations ? 0.ms : 120.ms),
          ],
        ),

          SizedBox(height: res.hp(2)),
          Text(
            'Eventos Disponibles',
            style: TextStyle(
              fontSize: res.dp(2.2),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: res.hp(1.5)),

          // Lista de eventos
          ...availableEvents.map((event) => _buildEventCard(event, res, theme)),
        ],
      ),
    );
  }

  // Tab de venta de tickets
  Widget _buildSellTab(Responsive res, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(res.wp(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vender Tickets',
            style: TextStyle(
              fontSize: res.dp(2.2),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: res.hp(1.5)),

          AppCard(
            padding: EdgeInsets.all(res.wp(4)),
            child: Column(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: res.dp(6),
                  color: AppTheme.primaryColor,
                ),
                SizedBox(height: res.hp(2)),
                Text(
                  'Vende tus tickets',
                  style: TextStyle(
                    fontSize: res.dp(2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: res.hp(1)),
                Text(
                  'Publica tus tickets no utilizados y recibe dinero por ellos de forma segura.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: res.dp(1.5),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: res.hp(2.5)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showSellTicketBottomSheet(context, res, theme),
                    icon: const Icon(Icons.add),
                    label: const Text('Publicar Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: res.hp(1.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: res.hp(3)),

          Text(
            'Tips para vender',
            style: TextStyle(
              fontSize: res.dp(1.8),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: res.hp(1.5)),

          _buildTipCard(
            'Precio competitivo',
            'Revisa precios similares antes de publicar',
            Icons.trending_up,
            res,
            theme,
          ),
          _buildTipCard(
            'Información completa',
            'Incluye todos los detalles del evento',
            Icons.info_outline,
            res,
            theme,
          ),
          _buildTipCard(
            'Responde rápido',
            'Contesta mensajes pronto para cerrar la venta',
            Icons.chat_bubble_outline,
            res,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventTicket event, Responsive res, ThemeData theme) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      animated: true,
      animationDuration: const Duration(milliseconds: 400),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del evento con placeholder moderno
              Container(
                width: res.wp(25),
                height: res.wp(25),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.event_rounded,
                  size: res.dp(4),
                  color: Colors.white,
                ),
              ),

              SizedBox(width: AppTheme.spacingNormal),

              // Información del evento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: AppTheme.fontSizeBodyLarge,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    AutoSizeText(
                      event.artist,
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: res.dp(1.6),
                          color: AppTheme.grey1,
                        ),
                        SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: AutoSizeText(
                            event.venue,
                            style: GoogleFonts.inter(
                              fontSize: AppTheme.fontSizeBodyNormal,
                              color: AppTheme.grey1,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: res.dp(1.6),
                          color: AppTheme.grey1,
                        ),
                        SizedBox(width: AppTheme.spacingSmall),
                        AutoSizeText(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: GoogleFonts.inter(
                            fontSize: AppTheme.fontSizeBodyNormal,
                            color: AppTheme.grey1,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          // Precio y botón de compra
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.hasDiscount) ...[
                    AutoSizeText(
                      '\$${event.originalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        decoration: TextDecoration.lineThrough,
                        color: AppTheme.grey1,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: AppTheme.spacingSmall / 2),
                  ],
                  AutoSizeText(
                    '\$${event.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeBodyLarge,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: 1,
                  ),
                  if (event.isResale)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingSmall / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      child: AutoSizeText(
                        'REVENTA',
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showBuyConfirmation(event, res, theme),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                  ),
                ),
                child: AutoSizeText(
                  'Comprar',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),

          if (event.availableTickets <= 5) ...[
            SizedBox(height: AppTheme.spacingSmall),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: res.wp(3),
                vertical: res.hp(0.5),
              ),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(res.wp(1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: res.dp(1.6),
                    color: Colors.red,
                  ),
                  SizedBox(width: res.wp(1)),
                  Text(
                    'Solo quedan ${event.availableTickets} tickets',
                    style: TextStyle(
                      fontSize: res.dp(1.2),
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipCard(
    String title,
    String description,
    IconData icon,
    Responsive res,
    ThemeData theme,
  ) {
    return AppCard(
      margin: EdgeInsets.only(bottom: res.hp(1)),
      padding: EdgeInsets.all(res.wp(4)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(res.wp(2)),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(res.wp(2)),
            ),
            child: Icon(icon, size: res.dp(2.5), color: AppTheme.primaryColor),
          ),
          SizedBox(width: res.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: res.dp(1.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: res.hp(0.5)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: res.dp(1.3),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(res.wp(6)),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(res.wp(6))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: res.wp(12),
              height: res.hp(0.5),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(res.wp(2)),
              ),
            ),
            SizedBox(height: res.hp(2)),
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: res.dp(2.2),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: res.hp(2)),
            Text('Filtros próximamente'),
            SizedBox(height: res.hp(2)),
          ],
        ),
      ),
    );
  }

  void _showBuyConfirmation(
    EventTicket event,
    Responsive res,
    ThemeData theme,
  ) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Confirmas la compra de este ticket?'),
            SizedBox(height: res.hp(1)),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Precio: \$${event.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              MotionToast(
                icon: Icons.check_circle_rounded,
                primaryColor: AppTheme.successColorLight,
                secondaryColor: Colors.white,
                title: Text(
                  'Compra exitosa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                description: Text(
                  'El ticket se agregó a tu lista',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                toastDuration: const Duration(seconds: 3),
                width: 320,
                height: 80,
                borderRadius: 16,
              ).show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  void _showSellTicketBottomSheet(
    BuildContext context,
    Responsive res,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(res.wp(6)),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(res.wp(6))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: res.wp(12),
              height: res.hp(0.5),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(res.wp(2)),
              ),
            ),
            SizedBox(height: res.hp(2)),
            Text(
              'Publicar Ticket',
              style: TextStyle(
                fontSize: res.dp(2.2),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: res.hp(2)),
            Text('Formulario de venta próximamente'),
            SizedBox(height: res.hp(2)),
          ],
        ),
      ),
    );
  }
}
