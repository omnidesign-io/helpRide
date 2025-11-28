import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';

final rideRequestProvider = StateProvider<RideOptions>((ref) {
  return const RideOptions();
});
