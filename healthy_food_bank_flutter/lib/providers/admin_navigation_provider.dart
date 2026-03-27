import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage admin navigation tab index
final adminNavigationProvider = StateProvider<int>((ref) => 0);
