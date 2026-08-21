import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendra/bootstrap.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/app_router.dart';
import 'package:spendra/core/theme/app_theme.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError caught: ${details.exception}');
  };

  try {
    final isar = await bootstrap();

    runApp(
      ProviderScope(
        overrides: [
          // Inject the initialised Isar instance into all providers.
          isarProvider.overrideWithValue(isar),
        ],
        child: const MomentumApp(),
      ),
    );
  } catch (e, st) {
    debugPrint('Bootstrap failure: $e\n$st');
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF6B5E)),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to start Momentum',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MomentumApp extends ConsumerWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    // Map our domain ThemeMode to Flutter's ThemeMode
    final flutterThemeMode = switch (themeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'Momentum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: flutterThemeMode,
      routerConfig: appRouter,
    );
  }
}
