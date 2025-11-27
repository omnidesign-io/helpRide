import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/ride_model.dart';

final rideRepositoryProvider = Provider((ref) => RideRepository(FirebaseFirestore.instance));

class RideRepository {
  final FirebaseFirestore _firestore;

  RideRepository(this._firestore);

  // Create a new ride request
  Future<String> createRideRequest({
    required String riderPhone,
    required GeoPoint pickupLocation,
    GeoPoint? dropoffLocation,
  }) async {
    final docRef = await _firestore.collection('rides').add({
      'riderPhone': riderPhone,
      'status': 'pending',
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Cancel a ride request
  Future<void> cancelRide(String rideId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
    });
  }

  // Accept a ride (Driver)
  Future<void> acceptRide({
    required String rideId,
    required String driverPhone,
  }) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'accepted',
      'driverPhone': driverPhone,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update ride status (Arrived, In Progress, Completed)
  Future<void> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    final Map<String, dynamic> updates = {
      'status': status,
    };

    if (status == 'arrived') {
      updates['arrivedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'in_progress') {
      updates['startedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'completed') {
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('rides').doc(rideId).update(updates);
  }

  // Stream rides for a specific rider (to show status)
  Stream<List<Ride>> streamRiderRides(String riderPhone) {
    return _firestore
        .collection('rides')
        .where('riderPhone', isEqualTo: riderPhone)
        .orderBy('createdAt', descending: true)
        .limit(1) // Only interested in the latest one usually
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList());
  }

  // Stream available rides for drivers
  // For MVP, we just show ALL pending rides. 
  // In real app, we'd filter by location (GeoFlutterFire or similar).
  Stream<List<Ride>> streamAvailableRides() {
    return _firestore
        .collection('rides')
        // .where('status', isEqualTo: 'pending') // Removed to allow seeing accepted rides
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Ride.fromFirestore(doc)).toList());
  }
}
