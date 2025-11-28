

class RideOptions {
  final List<String> vehicleTypeIds;
  final int passengerCount;
  final bool acceptPets;
  final bool acceptWheelchair;
  final bool acceptCargo;

  const RideOptions({
    this.vehicleTypeIds = const [], // Default to empty, meaning any or none selected initially
    this.passengerCount = 1,
    this.acceptPets = false,
    this.acceptWheelchair = false,
    this.acceptCargo = false,
  });

  RideOptions copyWith({
    List<String>? vehicleTypeIds,
    int? passengerCount,
    bool? acceptPets,
    bool? acceptWheelchair,
    bool? acceptCargo,
  }) {
    return RideOptions(
      vehicleTypeIds: vehicleTypeIds ?? this.vehicleTypeIds,
      passengerCount: passengerCount ?? this.passengerCount,
      acceptPets: acceptPets ?? this.acceptPets,
      acceptWheelchair: acceptWheelchair ?? this.acceptWheelchair,
      acceptCargo: acceptCargo ?? this.acceptCargo,
    );
  }
}
