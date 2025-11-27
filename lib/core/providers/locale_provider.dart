import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  // Default to Traditional Chinese (HK) as requested
  LocaleNotifier() : super(const Locale('zh', 'HK'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      state = const Locale('zh', 'HK');
    } else {
      state = const Locale('en');
    }
  }
}
