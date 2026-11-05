import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w51/core/config/app_config.dart';

import 'app/app.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi GoogleSignIn hanya pada platform yang didukung (Android, iOS, Web).
  // Di platform desktop seperti Linux/Windows/macOS, google_sign_in tidak memiliki implementasi native bawaan.
  final isSupportedPlatform = kIsWeb || Platform.isAndroid || Platform.isIOS;
  if (isSupportedPlatform) {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConfig.googleServerClientId.isEmpty
            ? null
            : AppConfig.googleServerClientId,
      );
    } catch (e) {
      debugPrint('GoogleSignIn.initialize failed: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(SharedPrefsStorage(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}
