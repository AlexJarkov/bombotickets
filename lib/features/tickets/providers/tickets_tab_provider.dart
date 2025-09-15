import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para controlar el tab seleccionado en la pantalla de tickets
final ticketsTabProvider = StateProvider<int>((ref) => 0);
