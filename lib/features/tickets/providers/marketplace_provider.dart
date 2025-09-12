import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/ticket.dart';
import '../repositories/tickets_repository.dart';
import 'filters_provider.dart';

final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  return TicketsRepository();
});

final marketplaceTicketsProvider =
    FutureProvider.autoDispose<List<MarketplaceOffer>>((ref) async {
      final repo = ref.read(ticketsRepositoryProvider);
      final items = await repo.getMarketplaceTickets();
      // Optionally keep the provider alive briefly to help with quick tab switches
      ref.keepAlive();
      return items;
    });

// Provider filtrado que considera la categoría seleccionada
final filteredMarketplaceTicketsProvider =
    Provider.autoDispose<AsyncValue<List<MarketplaceOffer>>>((ref) {
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
            filteredTickets = filteredTickets.where((offer) {
              return offer.ticketOfertado.evento.categoria.nombre ==
                  selectedCategory.nombre;
            }).toList();
          }

          // Filtrar por término de búsqueda
          if (searchTerm.isNotEmpty) {
            filteredTickets = filteredTickets.where((offer) {
              final evento = offer.ticketOfertado.evento;
              return evento.nombre.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ) ||
                  evento.lugar.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ) ||
                  evento.ciudad.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  );
            }).toList();
          }

          return AsyncValue.data(filteredTickets);
        },
      );
    });

// Provider para obtener tickets de un evento específico
final eventTicketsProvider = FutureProvider.autoDispose
    .family<List<MarketplaceOffer>, String>((ref, eventName) async {
      final repo = ref.read(ticketsRepositoryProvider);
      return repo.getMarketplaceTicketsByEvent(eventName);
    });

// Provider para zonas
final zonesProvider = FutureProvider.autoDispose<List<Zone>>((ref) async {
  final repo = ref.read(ticketsRepositoryProvider);
  return repo.getZones();
});

// Provider para filtrar tickets por zona en una pantalla de evento
final filteredEventTicketsProvider = Provider.autoDispose
    .family<AsyncValue<List<MarketplaceOffer>>, String>((ref, eventName) {
      final ticketsAsync = ref.watch(eventTicketsProvider(eventName));
      final selectedZone = ref.watch(selectedZoneProvider);

      return ticketsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
        data: (tickets) {
          var filteredTickets = tickets;

          // Filtrar por zona si hay una seleccionada
          if (selectedZone != null) {
            filteredTickets = filteredTickets.where((offer) {
              return offer.ticketOfertado.zona.zonaId == selectedZone.zonaId;
            }).toList();
          }

          return AsyncValue.data(filteredTickets);
        },
      );
    });
