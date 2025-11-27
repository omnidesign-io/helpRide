import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String id;
  final String riderPhone;
  final String? driverPhone;
  final String status; // 'pending', 'accepted', 'ongoing', 'completed', 'cancelled'
  final GeoPoint pickupLocation;
  final GeoPoint? dropoffLocation;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  Ride({
    required this.id,
    required this.riderPhone,
    this.driverPhone,
    required this.status,
    required this.pickupLocation,
    this.dropoffLocation,
    required this.createdAt,
    this.acceptedAt,
  });

  factory Ride.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ride(
      id: doc.id,
      riderPhone: data['riderPhone'] ?? '',
      driverPhone: data['driverPhone'],
      status: data['status'] ?? 'pending',
      pickupLocation: data['pickupLocation'] as GeoPoint,
      dropoffLocation: data['dropoffLocation'] as GeoPoint?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'riderPhone': riderPhone,
      'driverPhone': driverPhone,
      'status': status,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }
}
