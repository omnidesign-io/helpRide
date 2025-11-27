import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:helpride/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'features/home/presentation/landing_page.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/profile_screen.dart';
import 'features/rides/presentation/request_ride_screen.dart';
import 'features/rides/presentation/driver_dashboard_screen.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        if (kIsWeb) {
          return SelectionArea(child: child);
        }
        return child;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/profile/:phone',
          builder: (context, state) {
            final phone = state.pathParameters['phone']!;
            return ProfileScreen(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: '/request-ride/:phone',
          builder: (context, state) {
            final phone = state.pathParameters['phone']!;
            return RequestRideScreen(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: '/driver-dashboard/:phone',
          builder: (context, state) {
            final phone = state.pathParameters['phone']!;
            return DriverDashboardScreen(phoneNumber: phone);
          },
        ),
      ],
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
