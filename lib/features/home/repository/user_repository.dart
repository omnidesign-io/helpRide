import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required String uid,
    required String username,
    String? telegramHandle,
    bool isUsernameChanged = false,
  }) async {
    final data = {
      'username': username,
      'telegramHandle': telegramHandle,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (isUsernameChanged) {
      data['lastUsernameChange'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> updateUserVehicle(String uid, Map<String, dynamic> vehicleData) async {
    await _firestore.collection('users').doc(uid).update({
      'vehicle': vehicleData,
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Stream User Data
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  // Helper to find user by phone (useful for admin or initial checks)
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserByPhone(String phoneNumber) async {
    final query = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }
}
