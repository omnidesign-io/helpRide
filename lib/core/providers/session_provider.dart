import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final String uid;
  final String phoneNumber;
  final String? username;
  final String? sessionToken;
  final String role; // Added role

  UserSession({
    required this.uid,
    required this.phoneNumber,
    this.username,
    this.sessionToken,
    this.role = 'rider', // Default to rider
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'username': username,
      'sessionToken': sessionToken,
      'role': role,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> map) {
    return UserSession(
      uid: map['uid'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String,
      username: map['username'] as String?,
      sessionToken: map['sessionToken'] as String?,
      role: map['role'] as String? ?? 'rider',
    );
  }
}

class SessionNotifier extends StateNotifier<UserSession?> {
  SessionNotifier() : super(null);

  static const _key = 'user_session';

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        state = UserSession.fromJson(json.decode(jsonStr));
      } catch (e) {
        await prefs.remove(_key);
      }
    }
  }

  Future<void> setSession(UserSession session) async {
    state = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(session.toJson()));
  }

  Future<void> clearSession() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> updateRole(String role) async {
    if (state == null) return;
    final newSession = UserSession(
      uid: state!.uid,
      phoneNumber: state!.phoneNumber,
      username: state!.username,
      sessionToken: state!.sessionToken,
      role: role,
    );
    await setSession(newSession);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, UserSession?>((ref) {
  return SessionNotifier();
});
