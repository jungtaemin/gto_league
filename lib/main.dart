import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'core/utils/sound_manager.dart';
import 'data/services/database_helper.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await SoundManager.preloadAll();
  // Test: play a sound 2 seconds after launch to verify audio works
  Future.delayed(const Duration(seconds: 2), () {
    SoundManager.play(SoundType.correct);
  });
  await DatabaseHelper.instance.initDatabase();
  await SupabaseService.initialize(); // Initialize Supabase

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
