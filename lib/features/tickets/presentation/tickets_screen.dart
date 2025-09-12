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
import '../entities/ticket.dart';
import '../entities/real_event.dart';
import '../providers/marketplace_provider.dart';
import '../providers/real_events_provider.dart';
import '../widgets/real_event_card.dart';

// Provider para manejar el estado de la pantalla de tickets
final ticketsTabProvider = StateProvider<int>((ref) => 0);

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
    _tabController = TabController(length: 2, vsync: this);
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
                // Header con título y búsqueda
                _buildHeader(res, theme),

                // Filtros de categoría
                _buildCategoryFilters(res, theme),

                // Contenido con pestañas
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // Tab bar
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: res.wp(4)),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: AppTheme.grey1,
                            labelStyle: GoogleFonts.inter(
                              fontSize: AppTheme.fontSizeBodyNormal,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: GoogleFonts.inter(
                              fontSize: AppTheme.fontSizeBodyNormal,
                              fontWeight: FontWeight.w500,
                            ),
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                              insets: EdgeInsets.symmetric(
                                horizontal: res.wp(10),
                              ),
                            ),
                            tabs: const [
                              Tab(text: 'Comprar'),
                              Tab(text: 'Mis Tickets'),
                            ],
                          ),
                        ),

                        // Tab views
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildBuyTab(res, theme),
                              _buildMyTicketsTab(res, theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive res, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      child: Column(
        children: [
          // Título
          Text(
                'Tickets',
                style: GoogleFonts.poppins(
                  fontSize: AppTheme.fontSizeH1,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutBack),

          SizedBox(height: AppTheme.spacingMedium),

          // Barra de búsqueda
          GlassSearchBar(
                controller: _searchController,
                hintText: 'Buscar eventos...',
                onChanged: (query) {
                  // Podrías usar el query para filtrar aquí si implementas el provider
                },
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(Responsive res, ThemeData theme) {
    final categoriesAsync = ref.watch(eventCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (categories) => Container(
        height: res.hp(6),
        margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: res.wp(4)),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin: EdgeInsets.only(right: res.wp(2)),
                child: FilterChip(
                  label: Text('Todos'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    }
                  },
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selectedCategory == null
                        ? AppTheme.primaryColor
                        : AppTheme.grey1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            final category = categories[index - 1];
            final isSelected = selectedCategory?.id == category.id;

            return Container(
              margin: EdgeInsets.only(right: res.wp(2)),
              child: FilterChip(
                label: Text(category.nombre),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = selected
                      ? category
                      : null;
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBuyTab(Responsive res, ThemeData theme) {
    final eventsAsync = ref.watch(filteredRealEventsProvider);

    return eventsAsync.when(
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
              'Error al cargar eventos',
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
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: res.dp(8), color: AppTheme.grey1),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  'No hay eventos disponibles',
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Intenta con otros filtros de búsqueda',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: AppTheme.grey1,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(res.wp(4)),
          child: Column(
            children: events
                .asMap()
                .entries
                .map(
                  (entry) =>
                      RealEventCard(
                            event: entry.value,
                            onTap: () =>
                                _showEventDetails(entry.value, res, theme),
                          )
                          .animate(
                            delay: Duration(milliseconds: entry.key * 100),
                          )
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.3, duration: 400.ms),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildMyTicketsTab(Responsive res, ThemeData theme) {
    final myTicketsAsync = ref.watch(marketplaceTicketsProvider);

    return myTicketsAsync.when(
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
          ],
        ),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_num_outlined,
                  size: res.dp(8),
                  color: AppTheme.grey1,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  'No tienes tickets',
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Compra tickets en la pestaña "Comprar"',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: AppTheme.grey1,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(res.wp(4)),
          child: Column(
            children: [
              ...tickets
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildMyTicketCard(entry.value, res, theme)
                        .animate(delay: Duration(milliseconds: entry.key * 100))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3, duration: 400.ms),
                  )
                  .toList(),
              SizedBox(height: res.hp(4)),
              // Tips para vendedores
              _buildSellingTips(res, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyTicketCard(
    EventTicket ticket,
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
              // QR Code placeholder
              Container(
                width: res.wp(20),
                height: res.wp(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  border: Border.all(
                    color: AppTheme.grey1.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.qr_code,
                  size: res.dp(4),
                  color: AppTheme.grey1,
                ),
              ),

              SizedBox(width: AppTheme.spacingNormal),

              // Información del ticket
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: GoogleFonts.poppins(
                        fontSize: AppTheme.fontSizeBodyLarge,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppTheme.spacingSmall / 2),

                    Text(
                      ticket.venue,
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: AppTheme.spacingSmall / 2),

                    Text(
                      '${ticket.date.day}/${ticket.date.month}/${ticket.date.year}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        color: AppTheme.grey1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          // Estado del ticket
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: AppTheme.spacingSmall / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: res.dp(1.6),
                  color: Colors.green,
                ),
                SizedBox(width: 4),
                Text(
                  'Válido',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellingTips(Responsive res, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips para vender',
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeBodyLarge,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppTheme.spacingMedium),
        _buildTipCard(
          'Precio competitivo',
          'Revisa precios similares antes de publicar',
          Icons.attach_money_rounded,
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
          'Respuesta rápida',
          'Contesta mensajes pronto para cerrar la venta',
          Icons.speed_rounded,
          res,
          theme,
        ),
      ],
    );
  }

  void _showEventDetails(RealEvent event, Responsive res, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categoría: ${event.categoria.nombre}'),
            const SizedBox(height: 8),
            Text('Organizador: ${event.organizador.nombre}'),
            const SizedBox(height: 8),
            Text('Lugar: ${event.lugar}, ${event.ciudad}'),
            const SizedBox(height: 8),
            Text('Fecha: ${event.fecha}'),
            const SizedBox(height: 8),
            Text('Máximo tickets: ${event.maxTickets}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
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
            padding: EdgeInsets.all(res.wp(2.5)),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(res.wp(2)),
            ),
            child: Icon(icon, size: res.dp(2.2), color: AppTheme.primaryColor),
          ),
          SizedBox(width: res.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: res.dp(1.8),
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: res.hp(0.3)),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: res.dp(1.6),
                    color: AppTheme.grey1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
