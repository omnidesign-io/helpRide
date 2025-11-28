import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpride/features/rides/domain/vehicle_type.dart';

enum RideStatus { pending, accepted, arrived, riding, completed, cancelled }

class RideModel {
  final String id;
  final String shortId; // 8-digit unique ID
  final String riderId; // UID
  final String? driverId; // UID
  final String riderName; // Denormalized for data retention
  final String? driverName; // Denormalized for data retention
  final String riderPhone;
  final String? driverPhone;
  final String? riderTelegram;
  final String? driverTelegram;
  final String pickupAddress;
  final String destinationAddress;
  final RideStatus status;
  final DateTime createdAt;
  final int passengerCount;
  final VehicleType vehicleType;
  final bool acceptPets;
  final bool acceptWheelchair;
  final bool acceptCargo;
  final List<Map<String, dynamic>> auditTrail;

  RideModel({
    required this.id,
    required this.shortId,
    required this.riderId,
    this.driverId,
    required this.riderName,
    this.driverName,
    required this.riderPhone,
    this.driverPhone,
    this.riderTelegram,
    this.driverTelegram,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.status,
    required this.createdAt,
    this.passengerCount = 1,
    this.vehicleType = VehicleType.sedan,
    this.acceptPets = false,
    this.acceptWheelchair = false,
    this.acceptCargo = false,
    this.auditTrail = const [],
  });

  // From Firestore
  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideModel(
      id: doc.id,
      shortId: data['shortId'] ?? '00000000',
      riderId: data['riderId'] ?? '',
      driverId: data['driverId'],
      riderName: data['riderName'] ?? 'Unknown Rider',
      driverName: data['driverName'],
      riderPhone: data['riderPhone'] ?? '',
      driverPhone: data['driverPhone'],
      riderTelegram: data['riderTelegram'],
      driverTelegram: data['driverTelegram'],
      pickupAddress: data['pickupAddress'] ?? '',
      destinationAddress: data['destinationAddress'] ?? '',
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
      auditTrail: List<Map<String, dynamic>>.from(data['auditTrail'] ?? []),
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'shortId': shortId,
      'riderId': riderId,
      'driverId': driverId,
      'riderName': riderName,
      'driverName': driverName,
      'riderPhone': riderPhone,
      'driverPhone': driverPhone,
      'riderTelegram': riderTelegram,
      'driverTelegram': driverTelegram,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'passengerCount': passengerCount,
      'vehicleType': vehicleType.toString().split('.').last,
      'acceptPets': acceptPets,
      'acceptWheelchair': acceptWheelchair,
      'acceptCargo': acceptCargo,
      'auditTrail': auditTrail,
    };
  }

  bool get isActive => status == RideStatus.pending || status == RideStatus.accepted || status == RideStatus.arrived || status == RideStatus.riding;
}
