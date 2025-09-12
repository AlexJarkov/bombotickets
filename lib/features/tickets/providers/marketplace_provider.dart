import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/ticket.dart';
import '../repositories/marketplace_repository.dart';
import 'filters_provider.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

final marketplaceTicketsProvider = FutureProvider.autoDispose<List<EventTicket>>((
  ref,
) async {
  final repo = ref.read(marketplaceRepositoryProvider);
  final items = await repo.fetchMarketplaceTickets();
  // Optionally keep the provider alive briefly to help with quick tab switches
  ref.keepAlive();
  return items;
});

// Provider filtrado que considera la categoría seleccionada
final filteredMarketplaceTicketsProvider =
    Provider.autoDispose<AsyncValue<List<EventTicket>>>((ref) {
      final ticketsAsync = ref.watch(marketplaceTicketsProvider);
      final selectedCategory = ref.watch(selectedCategoryProvider);
      final searchTerm = ref.watch(searchTermProvider);

      return ticketsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
        data: (tickets) {
          var filteredTickets = tickets;

          // Filtrar por categoría
          if (selectedCategory != null) {
            filteredTickets = filteredTickets.where((ticket) {
              // Aquí necesitarías una forma de relacionar el ticket con su categoría
              // Por ahora simulo la categoría basada en el nombre del evento
              return _getEventCategory(ticket.title) == selectedCategory.nombre;
            }).toList();
          }

          // Filtrar por término de búsqueda
          if (searchTerm.isNotEmpty) {
            filteredTickets = filteredTickets.where((ticket) {
              return ticket.title.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ) ||
                  ticket.artist.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ) ||
                  ticket.venue.toLowerCase().contains(searchTerm.toLowerCase());
            }).toList();
          }

          return AsyncValue.data(filteredTickets);
        },
      );
    });

// Helper function para determinar categoría basada en el nombre (temporal)
String _getEventCategory(String eventTitle) {
  final title = eventTitle.toLowerCase();
  if (title.contains('concierto') ||
      title.contains('música') ||
      title.contains('festival')) {
    return 'Conciertos';
  } else if (title.contains('partido') ||
      title.contains('fútbol') ||
      title.contains('deportes')) {
    return 'Partidos';
  }
  return 'Conciertos'; // Por defecto
}
