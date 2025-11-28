import 'package:cloud_firestore/cloud_firestore.dart';


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
  final String? driverLicensePlate; // Added field
  final String? driverVehicleColor; // Added field
  final String? driverVehicleTypeId; // The actual vehicle type of the driver
  final String pickupAddress;
  final String destinationAddress;
  final RideStatus status;
  final DateTime createdAt;
  final DateTime? scheduledTime; // New field for scheduled rides
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int passengerCount;
  final List<String> requestedVehicleTypeIds; // Changed from single enum to list of IDs
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
    this.driverLicensePlate,
    this.driverVehicleColor,
    this.driverVehicleTypeId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.status,
    required this.createdAt,
    this.scheduledTime,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    required this.passengerCount,
    required this.requestedVehicleTypeIds,
    required this.acceptPets,
    required this.acceptWheelchair,
    required this.acceptCargo,
    required this.auditTrail,
  });

  // From Firestore
  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle legacy vehicleType (single string) vs new requestedVehicleTypeIds (list)
    List<String> vehicleTypes = [];
    if (data['requestedVehicleTypeIds'] != null) {
      vehicleTypes = List<String>.from(data['requestedVehicleTypeIds']);
    } else if (data['vehicleType'] != null) {
      vehicleTypes = [data['vehicleType'] as String];
    } else {
      vehicleTypes = ['sedan']; // Fallback
    }

    return RideModel(
      id: doc.id,
      shortId: data['shortId'] ?? '',
      riderId: data['riderId'] ?? '',
      driverId: data['driverId'],
      riderName: data['riderName'] ?? '',
      driverName: data['driverName'],
      riderPhone: data['riderPhone'] ?? '',
      driverPhone: data['driverPhone'],
      riderTelegram: data['riderTelegram'],
      driverTelegram: data['driverTelegram'],
      driverLicensePlate: data['driverLicensePlate'],
      driverVehicleColor: data['driverVehicleColor'],
      driverVehicleTypeId: data['driverVehicleTypeId'],
      pickupAddress: data['pickupAddress'] ?? '',
      destinationAddress: data['destinationAddress'] ?? '',
      status: RideStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => RideStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledTime: data['scheduledTime'] != null 
          ? (data['scheduledTime'] as Timestamp).toDate() 
          : null,
      acceptedAt: data['acceptedAt'] != null ? (data['acceptedAt'] as Timestamp).toDate() : null,
      arrivedAt: data['arrivedAt'] != null ? (data['arrivedAt'] as Timestamp).toDate() : null,
      startedAt: data['startedAt'] != null ? (data['startedAt'] as Timestamp).toDate() : null,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      passengerCount: data['passengerCount'] ?? 1,
      requestedVehicleTypeIds: vehicleTypes,
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
      'driverLicensePlate': driverLicensePlate,
      'driverVehicleColor': driverVehicleColor,
      'driverVehicleTypeId': driverVehicleTypeId,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      if (scheduledTime != null) 'scheduledTime': Timestamp.fromDate(scheduledTime!),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'arrivedAt': arrivedAt != null ? Timestamp.fromDate(arrivedAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'passengerCount': passengerCount,
      'requestedVehicleTypeIds': requestedVehicleTypeIds,
      'acceptPets': acceptPets,
      'acceptWheelchair': acceptWheelchair,
      'acceptCargo': acceptCargo,
      'auditTrail': auditTrail,
    };
  }

  bool get isActive => status == RideStatus.pending || status == RideStatus.accepted || status == RideStatus.arrived || status == RideStatus.riding;
}
