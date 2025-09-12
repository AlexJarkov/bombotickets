import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import '../entities/ticket.dart';
import '../repositories/tickets_repository.dart';

final myTicketsProvider = FutureProvider.autoDispose<List<MarketplaceOffer>>((
  ref,
) async {
  // Tie to auth state so changes invalidate and refetch
  final auth = ref.watch(authProvider);
  final repo = TicketsRepository();
  final email = auth.user?.username;
  return repo.getMyMarketplaceOffers(forEmail: email);
});
