import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'core/utils/sound_manager.dart';
import 'core/utils/music_manager.dart';
import 'data/services/database_helper.dart';
import 'data/services/supabase_service.dart';
import 'features/home/widgets/gto/settings_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await SoundManager.preloadAll();
  await MusicManager.init();
  await applyStoredSettings(); // 저장된 설정값 복원
  await DatabaseHelper.instance.initDatabase();
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
