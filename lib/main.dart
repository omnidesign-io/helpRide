import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'features/home/presentation/landing_page.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/profile_screen.dart';
import 'features/rides/presentation/request_ride_screen.dart';
import 'features/rides/presentation/driver_dashboard_screen.dart';
import 'core/providers/locale_provider.dart';

import 'features/home/presentation/main_screen.dart';
import 'features/home/presentation/settings_screen.dart';
import 'features/rides/presentation/orders_screen.dart';
import 'package:helpride/features/rides/presentation/ride_details_screen.dart';

import 'package:helpride/features/rides/presentation/vehicle_selection_screen.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'features/home/presentation/vehicle_settings_screen.dart';
import 'core/providers/session_provider.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure the client has an authenticated session (anonymous by default).
  await FirebaseAuth.instance.signInAnonymously();

  // Hydrate user session from local storage before rendering the app.
  final sessionNotifier = SessionNotifier();
  await sessionNotifier.restore();

  runApp(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith((ref) => sessionNotifier),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LandingPage(),
          ),
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: OrdersScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/vehicle-selection',
          builder: (context, state) {
            final currentOptions = state.extra as RideOptions?;
            return VehicleSelectionScreen(currentOptions: currentOptions);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/request-ride',
      builder: (context, state) => const RequestRideScreen(),
    ),
    GoRoute(
      path: '/ride-details/:id',
      builder: (context, state) => RideDetailsScreen(
        rideId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/driver-dashboard',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/vehicle-settings',
      builder: (context, state) => const VehicleSettingsScreen(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'HelpRide',
      locale: locale, // Dynamic Locale
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
          surface: const Color(0xFFFDFDFD), // Almost white background
          surfaceContainer: const Color(0xFFF2F2F2), // Light grey containers
          surfaceContainerHigh: const Color(0xFFF2F2F2), // Same for consistency
        ),
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFFF2F2F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE6E6E6), // Slightly darker grey for inputs
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputBorderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputBorderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputBorderRadius),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kInputBorderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        // Remove default elevation for a flatter, modern look
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFFFDFDFD),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0, // Flat buttons
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kInputBorderRadius)),
          ),
        ),
      ),
      routerConfig: _router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh', 'HK'), // Traditional Chinese (Hong Kong)
      ],
    );
  }
}
