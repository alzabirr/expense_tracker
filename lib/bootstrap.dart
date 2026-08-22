import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendra/core/config/supabase_config.dart';
import 'package:spendra/core/database/database_seeder.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/features/expense/data/repositories/expense_repository_impl.dart';

/// Initialises Supabase and the Isar database and seeds default data on first launch.
/// Call before [ProviderScope] wraps the app.
Future<Isar> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final isar = await openIsar();
  await DatabaseSeeder.seedDefaultCategories(isar);

  // Background cleanup of soft-deleted transactions older than 30 days
  ExpenseRepositoryImpl(isar).purgeOldDeleted(30).catchError((e) {
    debugPrint('Purge old deleted error: $e');
  });

  return isar;
}

