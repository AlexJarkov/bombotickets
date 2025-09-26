import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../entities/real_event.dart';
import '../providers/real_events_provider.dart';
import '../widgets/real_event_card.dart';
import 'event_tickets_screen.dart';

class BuyTicketsScreen extends ConsumerStatefulWidget {
  const BuyTicketsScreen({super.key});

  @override
  ConsumerState<BuyTicketsScreen> createState() => _BuyTicketsScreenState();
}

class _BuyTicketsScreenState extends ConsumerState<BuyTicketsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
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

                // Lista de eventos
                Expanded(
                  child: _buildEventsList(res, theme),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón de regreso
          Row(
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
                  'Comprar Tickets',
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.fontSizeH2,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          // Barra de búsqueda
          GlassSearchBar(
            controller: _searchController,
            hintText: 'Buscar eventos...',
            onChanged: (query) {
              ref.read(searchTermProvider.notifier).state = query;
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

  Widget _buildEventsList(Responsive res, ThemeData theme) {
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
                Icon(
                  Icons.event_busy,
                  size: res.dp(8),
                  color: AppTheme.grey1,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  'No hay eventos disponibles',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Prueba cambiando los filtros o intenta más tarde',
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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allRealEventsProvider);
          },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: res.wp(4)),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              
              return Container(
                margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                child: RealEventCard(
                  event: event,
                  onTap: () => _navigateToEventTickets(event),
                ),
              )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack);
            },
          ),
        );
      },
    );
  }

  void _navigateToEventTickets(RealEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventTicketsScreen(eventName: event.nombre),
      ),
    );
  }
}
