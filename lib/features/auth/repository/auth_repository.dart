import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
      GoogleSignIn(),
    ));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final _uuid = const Uuid();

  AuthRepository(this._auth, this._firestore, this._googleSignIn);

  // Sign in anonymously to access Firestore
  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String phoneNumber) async {
    await signInAnonymously();
    final querySnapshot = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Login (Existing User)
  Future<Map<String, String>> login(String phoneNumber) async {
    await signInAnonymously();
    final querySnapshot = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final doc = querySnapshot.docs.first;
    final data = doc.data();
    return {
      'uid': doc.id,
      'sessionToken': data['sessionToken'] as String? ?? '',
      'role': data['role'] as String? ?? 'rider',
      'username': data['username'] as String? ?? '',
    };
  }

  // Sign Up (New User)
  Future<Map<String, String>> signUp({
    required String phoneNumber,
    required String username,
    String? telegramHandle,
  }) async {
    await signInAnonymously();
    
    // Use Auth UID as Firestore Document ID
    final uid = _auth.currentUser!.uid;
    final userDocRef = _firestore.collection('users').doc(uid);
    final sessionToken = _uuid.v4();
    
    await userDocRef.set({
      'uid': _auth.currentUser?.uid, // Firebase Auth UID (Anonymous)
      'phoneNumber': phoneNumber,
      'sessionToken': sessionToken,
      'username': username,
      'telegramHandle': telegramHandle,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'rider', // Default
      'isOnline': true,
    });
    
    return {
      'uid': uid,
      'sessionToken': sessionToken,
      'role': 'rider',
      'username': username,
    };
  }

  // Sign in with Google and attempt to claim Superadmin role
  Future<void> signInWithGoogleAndClaimAdmin(String phoneNumber) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link Google Credential to the current Anonymous User
      if (_auth.currentUser != null) {
        await _auth.currentUser!.linkWithCredential(credential);
      } else {
        await _auth.signInWithCredential(credential);
      }

      // Find user by phone number
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found for admin claim');
      }

      final userDocRef = querySnapshot.docs.first.reference;
      await userDocRef.update({
        'role': 'superadmin',
        'googleEmail': googleUser.email,
      });
      
    } catch (e) {
      print("Error claiming admin: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
