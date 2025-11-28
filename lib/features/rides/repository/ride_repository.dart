import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/ride_model.dart';
import '../domain/ride_options.dart';

final rideRepositoryProvider = Provider((ref) => RideRepository(FirebaseFirestore.instance));

class RideRepository {
  final FirebaseFirestore _firestore;

  RideRepository(this._firestore);

  // IMPORTANT: When modifying ride lifecycle methods (create, accept, cancel, update status),
  // ALWAYS ensure you append a corresponding event to the 'auditTrail' field in Firestore.
  // This is crucial for tracking the history of the ride.



  // ... inside createRideRequest
  Future<String> createRideRequest({
    required String riderId,
    required String riderName,
    required String riderPhone,
    String? riderTelegram,
    required String pickupAddress,
    required String destinationAddress,
    required RideOptions options,
  }) async {
    // Pre-check for existing active rides (Legacy/Fallback)
    // This catches cases where lastRideId might be missing or out of sync,
    // but isn't race-condition proof on its own.
    try {
      final activeRidesSnapshot = await _firestore
          .collection('rides')
          .where('riderId', isEqualTo: riderId)
          .where('status', whereIn: ['pending', 'accepted', 'arrived', 'riding'])
          .get();
      
      if (activeRidesSnapshot.docs.isNotEmpty) {
        throw Exception('You already have an active ride.');
      }
    } catch (e) {
      rethrow;
    }

    final newRideRef = _firestore.collection('rides').doc();
    final ride = RideModel(
      id: newRideRef.id,
      shortId: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      riderTelegram: riderTelegram,
      driverPhone: null,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      status: RideStatus.pending,
      createdAt: DateTime.now(),
      passengerCount: options.passengerCount,
      vehicleType: options.vehicleType,
      acceptPets: options.acceptPets,
      acceptWheelchair: options.acceptWheelchair,
      acceptCargo: options.acceptCargo,
      auditTrail: [
        {
          'action': 'created',
          'timestamp': Timestamp.now(),
          'actorId': riderId,
        }
      ],
    );

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Lock User Document
        final userRef = _firestore.collection('users').doc(riderId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User profile not found. Please restart the app.');
        }

        // 2. Check Last Ride (Strict Serialization)
        final data = userDoc.data();
        if (data != null && data.containsKey('lastRideId')) {
          final lastRideId = data['lastRideId'] as String?;
          if (lastRideId != null && lastRideId.isNotEmpty) {
            final lastRideRef = _firestore.collection('rides').doc(lastRideId);
            final lastRideDoc = await transaction.get(lastRideRef);

            if (lastRideDoc.exists) {
              final lastRideStatus = lastRideDoc.data()?['status'];
              if (['pending', 'accepted', 'arrived', 'riding'].contains(lastRideStatus)) {
                throw Exception('You already have an active ride processing.');
              }
            }
          }
        }

        // 3. Perform Writes
        transaction.set(newRideRef, ride.toMap());
        transaction.update(userRef, {'lastRideId': newRideRef.id});
      });

      return newRideRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Cancel a ride request
  Future<void> cancelRide(String rideId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
      'auditTrail': FieldValue.arrayUnion([
        {
          'action': 'cancelled',
          'timestamp': DateTime.now(),
        }
      ]),
    });
  }

  // Accept a ride (Driver)
  Future<void> acceptRide({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
    String? driverTelegram,
  }) async {
    // Fetch driver's vehicle info
    String? driverLicensePlate;
    try {
      final userDoc = await _firestore.collection('users').doc(driverId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('vehicle')) {
          final vehicle = data['vehicle'] as Map<String, dynamic>;
          driverLicensePlate = vehicle['licensePlate'] as String?;
        }
      }
    } catch (e) {
      // Ignore error, proceed without license plate if fetch fails
      print('Error fetching driver vehicle info: $e');
    }

    await _firestore.collection('rides').doc(rideId).update({
      'status': 'accepted',
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverTelegram': driverTelegram,
      'driverLicensePlate': driverLicensePlate,
      'acceptedAt': FieldValue.serverTimestamp(),
      'auditTrail': FieldValue.arrayUnion([
        {
          'action': 'accepted',
          'timestamp': DateTime.now(),
          'actorId': driverId,
        }
      ]),
    });
  }

  // Update ride status (Arrived, In Progress, Completed)
  Future<void> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    final Map<String, dynamic> updates = {
      'status': status,
      'auditTrail': FieldValue.arrayUnion([
        {
          'action': status,
          'timestamp': DateTime.now(),
        }
      ]),
    };

    if (status == 'arrived') {
      updates['arrivedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'riding') { // Was 'in_progress'
      updates['startedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'completed') {
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('rides').doc(rideId).update(updates);
  }

  // Stream active ride for a specific rider
  Stream<List<RideModel>> streamRiderRides(String riderId) {
    return _firestore
        .collection('rides')
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList());
  }

  // Stream active rides for a specific driver
  Stream<List<RideModel>> streamDriverRides(String driverId) {
    return _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['accepted', 'arrived', 'riding']) // Only active states
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList());
  }

  // Stream ride history (all rides)
  Stream<List<RideModel>> streamRideHistory(String userId, {bool isDriver = false}) {
    Query query = _firestore.collection('rides');

    if (isDriver) {
      query = query.where('driverId', isEqualTo: userId);
    } else {
      query = query.where('riderId', isEqualTo: userId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList());
  }

  // Stream available rides for drivers
  // For MVP, we just show ALL pending rides. 
  // In real app, we'd filter by location (GeoFlutterFire or similar).
  Stream<List<RideModel>> streamAvailableRides() {
    return _firestore
        .collection('rides')
        // .where('status', isEqualTo: 'pending') // Removed to allow seeing accepted rides
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList());
  }
  // Get a single ride by ID
  Future<RideModel> getRide(String rideId) async {
    final doc = await _firestore.collection('rides').doc(rideId).get();
    if (!doc.exists) {
      throw Exception('Ride not found');
    }
    return RideModel.fromFirestore(doc);
  }

  // Stream a single ride
  Stream<RideModel> streamRide(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) throw Exception('Ride not found');
          return RideModel.fromFirestore(doc);
        });
  }
}
