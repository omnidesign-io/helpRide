import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';

enum RideStatus { pending, accepted, arrived, riding, completed, cancelled }

class RideModel {
  final String id;
  final String shortId; // 8-digit unique ID
  final String riderPhone;
  final String? driverPhone;
  final GeoPoint pickupLocation;
  final RideStatus status;
  final DateTime createdAt;
  final int passengerCount;
  final VehicleType vehicleType;
  final bool acceptPets;
  final bool acceptWheelchair;
  final bool acceptCargo;

  RideModel({
    required this.id,
    required this.shortId,
    required this.riderPhone,
    this.driverPhone,
    required this.pickupLocation,
    required this.status,
    required this.createdAt,
    this.passengerCount = 1,
    this.vehicleType = VehicleType.sedan,
    this.acceptPets = false,
    this.acceptWheelchair = false,
    this.acceptCargo = false,
  });

  // From Firestore
  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideModel(
      id: doc.id,
      shortId: data['shortId'] ?? '00000000',
      riderPhone: data['riderPhone'] ?? '',
      driverPhone: data['driverPhone'],
      pickupLocation: data['pickupLocation'] as GeoPoint,
      status: RideStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => RideStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      passengerCount: data['passengerCount'] ?? 1,
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.toString().split('.').last == data['vehicleType'],
        orElse: () => VehicleType.sedan,
      ),
      acceptPets: data['acceptPets'] ?? false,
      acceptWheelchair: data['acceptWheelchair'] ?? false,
      acceptCargo: data['acceptCargo'] ?? false,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'shortId': shortId,
      'riderPhone': riderPhone,
      'driverPhone': driverPhone,
      'pickupLocation': pickupLocation,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'passengerCount': passengerCount,
      'vehicleType': vehicleType.toString().split('.').last,
      'acceptPets': acceptPets,
      'acceptWheelchair': acceptWheelchair,
      'acceptCargo': acceptCargo,
    };
  }

  bool get isActive => status == RideStatus.pending || status == RideStatus.accepted || status == RideStatus.arrived || status == RideStatus.riding;
}
