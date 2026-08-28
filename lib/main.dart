import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendra/bootstrap.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/core/providers/providers.dart';
import 'package:spendra/core/router/app_router.dart';
import 'package:spendra/core/router/route_names.dart';
import 'package:spendra/core/theme/app_theme.dart';
import 'package:spendra/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError caught: ${details.exception}');
  };

  try {
    final isar = await bootstrap();
    final settings = await SettingsRepositoryImpl(isar).get();
    final currentUser = Supabase.instance.client.auth.currentUser;

    final String initialLocation;
    if (currentUser == null) {
      initialLocation =
          settings.isFirstLaunch ? RouteNames.onboarding : RouteNames.signup;
    } else {
      initialLocation = RouteNames.dashboard;
    }
    final router = createAppRouter(initialLocation: initialLocation);

    runApp(
      ProviderScope(
        overrides: [
          // Inject the initialised Isar instance into all providers.
          isarProvider.overrideWithValue(isar),
        ],
        child: OwlyApp(router: router),
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
                    'Unable to start Owly',
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

class OwlyApp extends ConsumerStatefulWidget {
  const OwlyApp({super.key, required this.router});

  final GoRouter router;

  @override
  ConsumerState<OwlyApp> createState() => _OwlyAppState();
}

class _OwlyAppState extends ConsumerState<OwlyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto-sync pending offline transactions when user returns to the app
      ref.read(authControllerProvider.notifier).syncData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Map our domain ThemeMode to Flutter's ThemeMode
    final flutterThemeMode = switch (themeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'Owly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: flutterThemeMode,
      routerConfig: widget.router,
    );
  }
}
