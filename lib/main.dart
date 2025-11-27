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
import 'package:helpride/features/rides/presentation/vehicle_selection_screen.dart';
import 'package:helpride/features/rides/domain/ride_options.dart';
import 'features/home/presentation/vehicle_settings_screen.dart';
import 'core/providers/session_provider.dart';

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
        return SelectionArea(child: MainScreen(child: child));
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
      path: '/profile/:phone',
      builder: (context, state) => ProfileScreen(
        phoneNumber: state.pathParameters['phone']!,
      ),
    ),
    GoRoute(
      path: '/request-ride/:phone',
      builder: (context, state) => RequestRideScreen(
        phoneNumber: state.pathParameters['phone']!,
      ),
    ),
    GoRoute(
      path: '/driver-dashboard/:phone',
      builder: (context, state) => DriverDashboardScreen(
        phoneNumber: state.pathParameters['phone']!,
      ),
    ),
    GoRoute(
      path: '/vehicle-settings/:phone',
      builder: (context, state) => VehicleSettingsScreen(
        phoneNumber: state.pathParameters['phone']!,
      ),
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
        ),
        // Remove default elevation for a flatter, modern look
        appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0, // Flat buttons
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
