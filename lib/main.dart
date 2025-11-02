import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/auth_gate.dart';
import 'services/auth/auth_controller.dart';
import 'services/friends/friends_controller.dart';
import 'services/link/link_controller.dart';
import 'services/car/android_auto_manager.dart';
import 'services/car/car_scoreboard.dart';
import 'services/car/carplay_manager.dart';
import 'services/link/link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();

  final authController = AuthController(prefs);
  await authController.initialize();

  final linkService = LinkService(prefs);
  final linkController = LinkController(authController, linkService);
  await linkController.initialize();

  final friendsController = FriendsController(prefs);
  await friendsController.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  final providers = <SingleChildWidget>[
    ChangeNotifierProvider<AuthController>.value(value: authController),
    ChangeNotifierProvider<LinkController>.value(value: linkController),
    ChangeNotifierProvider<FriendsController>.value(
      value: friendsController,
    ),
    Provider<CarScoreboardController>(
      create: (_) {
        final controller = CarScoreboardController(linkController);
        controller.initialize();
        return controller;
      },
      dispose: (_, controller) => controller.dispose(),
    ),
  ];

  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      providers.add(
        ProxyProvider<CarScoreboardController, CarPlayManager>(
          update: (_, scoreboard, previous) {
            final manager = previous ?? CarPlayManager(scoreboard);
            manager.initialize();
            return manager;
          },
          dispose: (_, manager) => manager.dispose(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      providers.add(
        ProxyProvider<CarScoreboardController, AndroidAutoManager>(
          update: (_, scoreboard, previous) {
            final manager = previous ?? AndroidAutoManager(scoreboard);
            manager.initialize();
            return manager;
          },
          dispose: (_, manager) => manager.dispose(),
        ),
      );
    }
  }

  runApp(
    MultiProvider(
      providers: providers,
      child: const RoadTripGamesApp(),
    ),
  );
}

class RoadTripGamesApp extends StatelessWidget {
  const RoadTripGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2979FF),
      brightness: Brightness.light,
    ).copyWith(
      secondary: const Color(0xFF7C4DFF),
      tertiary: const Color(0xFFFF9100),
    );

    return MaterialApp(
      title: 'Road Trip Games',
      theme: ThemeData(
        colorScheme: baseColorScheme,
        scaffoldBackgroundColor: baseColorScheme.surface,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ).apply(
          bodyColor: baseColorScheme.onSurface,
          displayColor: baseColorScheme.onSurface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: baseColorScheme.onSurface,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: baseColorScheme.onSurface,
          ),
        ),
        cardTheme: CardThemeData(
          color: baseColorScheme.surfaceContainerHigh,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: baseColorScheme.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: baseColorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: baseColorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: baseColorScheme.primary, width: 2),
          ),
          labelStyle: TextStyle(color: baseColorScheme.onSurfaceVariant),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: baseColorScheme.primary,
            foregroundColor: baseColorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 24,
            ),
            side: BorderSide(color: baseColorScheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: baseColorScheme.surfaceContainerLow,
          selectedColor: baseColorScheme.primaryContainer,
          disabledColor: baseColorScheme.surfaceContainerHigh,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: baseColorScheme.onSurfaceVariant,
          ),
          secondaryLabelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: baseColorScheme.primary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        dividerTheme: DividerThemeData(
          space: 24,
          thickness: 1,
          color: baseColorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: baseColorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: baseColorScheme.onSurface,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 14,
            color: baseColorScheme.onSurfaceVariant,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
