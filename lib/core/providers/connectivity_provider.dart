import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that streams the current connectivity status.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  
  // Check initial status
  try {
    final initial = await connectivity.checkConnectivity();
    yield initial;
  } catch (e) {
    // Fallback to waiting for stream if initial check fails
  }

  // Listen for changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield results;
  }
});

/// Provider that returns true if connected to the internet, false otherwise.
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  
  return connectivityAsync.when(
    data: (results) {
      // If the list contains .none, it means we are offline.
      // If it contains mobile, wifi, ethernet, etc., we are online.
      return !results.contains(ConnectivityResult.none);
    },
    loading: () => true, // Assume connected while loading to avoid flashing error
    error: (_, __) => false, // Assume disconnected on error
  );
});
