import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/gto_home_screen.dart';
import 'features/game/game_screen.dart';
import 'features/ranking/ranking_screen.dart';
import 'features/game_over/game_over_screen.dart';
import 'features/privacy/privacy_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holdem All-In Fold',
      theme: AppTheme.neoBrutalistTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const GtoHomeScreen(),
        '/game': (context) => const GameScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/game-over': (context) => const GameOverScreen(),
        '/privacy': (context) => const PrivacyScreen(),
      },
    );
  }
}
