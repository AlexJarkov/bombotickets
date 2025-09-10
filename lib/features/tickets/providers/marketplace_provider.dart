import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/ticket.dart';
import '../repositories/marketplace_repository.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

final marketplaceTicketsProvider = FutureProvider.autoDispose<List<EventTicket>>((ref) async {
  final repo = ref.read(marketplaceRepositoryProvider);
  final items = await repo.fetchMarketplaceTickets();
  // Optionally keep the provider alive briefly to help with quick tab switches
  ref.keepAlive();
  return items;
});

