import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import '../entities/ticket.dart';
import '../repositories/my_tickets_repository.dart';

final myTicketsRepositoryProvider = Provider<MyTicketsRepository>((ref) {
  return MyTicketsRepository();
});

final myTicketsProvider = FutureProvider.autoDispose<List<MyTicket>>((ref) async {
  // Tie to auth state so changes invalidate and refetch
  final auth = ref.watch(authProvider);
  final repo = ref.read(myTicketsRepositoryProvider);
  final email = auth.user?.username;
  return repo.fetchMyTickets(forEmail: email);
});
