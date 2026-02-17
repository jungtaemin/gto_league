import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'core/utils/sound_manager.dart';
import 'data/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SoundManager.preloadAll();
  await DatabaseHelper.instance.initDatabase();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
