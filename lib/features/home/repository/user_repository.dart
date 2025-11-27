import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final userRepositoryProvider = Provider((ref) => UserRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ));

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository(this._firestore, this._auth);

  // Update User Profile (Username, Telegram)
  Future<void> updateProfile({
    required String phoneNumber,
    required String username,
    String? telegramHandle,
  }) async {
    await _firestore.collection('users').doc(phoneNumber).update({
      'username': username,
      'telegramHandle': telegramHandle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update Location
  Future<void> updateLocation(String phoneNumber) async {
    // 1. Request Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // 2. Get Position
    final position = await Geolocator.getCurrentPosition();

    // 3. Update Firestore
    await _firestore.collection('users').doc(phoneNumber).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }
  
  // Stream User Data
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String phoneNumber) {
    return _firestore.collection('users').doc(phoneNumber).snapshots();
  }
}
