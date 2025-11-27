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
    final userDoc = await _firestore.collection('users').doc(phoneNumber).get();
    return userDoc.exists;
  }

  // Login (Existing User)
  Future<void> login(String phoneNumber) async {
    await signInAnonymously();
    // In a real app, we'd trigger the approval flow here.
    // For MVP, we just ensure they are connected.
  }

  // Sign Up (New User)
  Future<String> signUp({
    required String phoneNumber,
    required String username,
    String? telegramHandle,
  }) async {
    await signInAnonymously();
    
    final userDocRef = _firestore.collection('users').doc(phoneNumber);
    final sessionToken = _uuid.v4();
    
    await userDocRef.set({
      'uid': _auth.currentUser?.uid,
      'phoneNumber': phoneNumber,
      'sessionToken': sessionToken,
      'username': username,
      'telegramHandle': telegramHandle,
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'rider', // Default
      'isOnline': true,
    });
    
    return sessionToken;
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
      // Note: This merges the accounts.
      if (_auth.currentUser != null) {
        await _auth.currentUser!.linkWithCredential(credential);
      } else {
        await _auth.signInWithCredential(credential);
      }

      // Attempt to claim Superadmin role
      // This will only succeed if the Firestore Rule allows it (i.e., email is in super_admins)
      final userDocRef = _firestore.collection('users').doc(phoneNumber);
      await userDocRef.update({
        'role': 'superadmin',
        'googleEmail': googleUser.email,
      });
      
    } catch (e) {
      print("Error claiming admin: $e");
      // If update fails (permission denied), it means they are NOT a superadmin.
      // We should probably handle this gracefully.
      rethrow;
    }
  }
}
