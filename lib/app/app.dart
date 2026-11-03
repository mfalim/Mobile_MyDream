import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_state_sync.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menyimpan data ke perangkat dan membersihkannya saat keluar.
    ref.watch(appStateSyncProvider);
    return MaterialApp.router(
      title: 'MyDream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
