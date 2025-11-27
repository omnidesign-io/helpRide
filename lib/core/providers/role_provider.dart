import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { rider, driver }

class RoleNotifier extends StateNotifier<UserRole> {
  RoleNotifier() : super(UserRole.rider);

  void toggleRole() {
    state = state == UserRole.rider ? UserRole.driver : UserRole.rider;
  }

  void setRole(UserRole role) {
    state = role;
  }
}

final roleProvider = StateNotifierProvider<RoleNotifier, UserRole>((ref) {
  return RoleNotifier();
});
