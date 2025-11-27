import 'package:helpride/features/rides/domain/vehicle_type.dart';

class RideOptions {
  final VehicleType vehicleType;
  final int passengerCount;
  final bool acceptPets;
  final bool acceptWheelchair;
  final bool acceptCargo;

  const RideOptions({
    required this.vehicleType,
    this.passengerCount = 1,
    this.acceptPets = false,
    this.acceptWheelchair = false,
    this.acceptCargo = false,
  });

  RideOptions copyWith({
    VehicleType? vehicleType,
    int? passengerCount,
    bool? acceptPets,
    bool? acceptWheelchair,
    bool? acceptCargo,
  }) {
    return RideOptions(
      vehicleType: vehicleType ?? this.vehicleType,
      passengerCount: passengerCount ?? this.passengerCount,
      acceptPets: acceptPets ?? this.acceptPets,
      acceptWheelchair: acceptWheelchair ?? this.acceptWheelchair,
      acceptCargo: acceptCargo ?? this.acceptCargo,
    );
  }
}
