import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/auth_gate.dart';
import 'styles/app_theme.dart';
import 'services/auth/auth_controller.dart';
import 'services/friends/friends_controller.dart';
import 'services/link/link_controller.dart';
import 'services/car/android_auto_manager.dart';
import 'services/car/car_scoreboard.dart';
import 'services/car/carplay_manager.dart';
import 'services/link/link_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase when platform config exists (optional on desktop).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Firebase unavailable on this platform — continuing in offline mode.',
      );
    }
  }

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
    return MaterialApp(
      title: 'Road Trip Games',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
