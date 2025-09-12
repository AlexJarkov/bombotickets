import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/real_event.dart';
import '../entities/event_type.dart';
import '../repositories/real_events_repository.dart';

// Provider para el repository de eventos reales
final realEventsRepositoryProvider = Provider<RealEventsRepository>((ref) {
  return RealEventsRepository();
});

// Provider para obtener todos los eventos
final allRealEventsProvider = FutureProvider.autoDispose<List<RealEvent>>((
  ref,
) async {
  final repo = ref.read(realEventsRepositoryProvider);
  final events = await repo.getAllEvents();
  ref.keepAlive();
  return events;
});

// Provider para las categorías (reutilizando)
final eventCategoriesProvider = FutureProvider<List<EventType>>((ref) async {
  final repo = ref.read(realEventsRepositoryProvider);
  return repo.getEventTypes();
});

// Provider para la categoría seleccionada (filtro)
final selectedCategoryProvider = StateProvider<EventType?>((ref) => null);

// Provider para el término de búsqueda
final searchTermProvider = StateProvider<String>((ref) => '');

// Provider filtrado que considera la categoría seleccionada y búsqueda
final filteredRealEventsProvider =
    Provider.autoDispose<AsyncValue<List<RealEvent>>>((ref) {
      final eventsAsync = ref.watch(allRealEventsProvider);
      final selectedCategory = ref.watch(selectedCategoryProvider);
      final searchTerm = ref.watch(searchTermProvider);

      return eventsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
        data: (events) {
          var filteredEvents = events;

          // Filtrar por categoría
          if (selectedCategory != null) {
            filteredEvents = filteredEvents.where((event) {
              return event.categoria.categoriaId == selectedCategory.id;
            }).toList();
          }

          // Filtrar por término de búsqueda
          if (searchTerm.isNotEmpty) {
            filteredEvents = filteredEvents.where((event) {
              final searchLower = searchTerm.toLowerCase();
              return event.nombre.toLowerCase().contains(searchLower) ||
                  event.lugar.toLowerCase().contains(searchLower) ||
                  event.ciudad.toLowerCase().contains(searchLower) ||
                  event.organizador.nombre.toLowerCase().contains(searchLower);
            }).toList();
          }

          return AsyncValue.data(filteredEvents);
        },
      );
    });
