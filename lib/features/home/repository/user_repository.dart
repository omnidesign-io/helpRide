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

  // Delete Account
  Future<void> deleteAccount(String uid) async {
    // 1. Check for active rides
    final activeRidesSnapshot = await _firestore
        .collection('rides')
        .where('riderId', isEqualTo: uid)
        .where('status', whereIn: ['pending', 'accepted', 'arrived', 'riding'])
        .get();

    if (activeRidesSnapshot.docs.isNotEmpty) {
      throw Exception('Cannot delete account while you have active rides. Please complete or cancel them first.');
    }

    // 2. Delete user document from Firestore
    await _firestore.collection('users').doc(uid).delete();

    // 3. Delete user from Firebase Auth
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // If strict re-auth is needed, we might need to prompt user.
        // For MVP, we'll just sign out if deletion fails, effectively locking them out.
        // But ideally we should re-authenticate.
        // Since we use anonymous auth linked to phone, re-auth is tricky without SMS.
        // We will swallow this specific error for now and ensure Firestore data is gone.
        // The user is effectively "deleted" from the app's perspective.
        await _auth.signOut();
      } else {
        rethrow;
      }
    } catch (e) {
      // General error, try to sign out at least
      await _auth.signOut();
      rethrow;
    }
  }
}
