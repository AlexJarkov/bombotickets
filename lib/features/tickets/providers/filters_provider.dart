import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/event_type.dart';
import '../entities/ticket.dart';
import '../repositories/tickets_repository.dart';

// Provider para las categorías
final eventCategoriesProvider = FutureProvider<List<EventType>>((ref) async {
  final repository = TicketsRepository();
  return repository.getEventTypes();
});

// Provider para la categoría seleccionada (filtro)
final selectedCategoryProvider = StateProvider<EventType?>((ref) => null);

// Provider para el término de búsqueda
final searchTermProvider = StateProvider<String>((ref) => '');

// Provider para la zona seleccionada (filtro por zona en eventos específicos)
final selectedZoneProvider = StateProvider<Zone?>((ref) => null);
