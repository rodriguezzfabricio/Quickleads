import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app/app.dart';
import 'core/network/supabase_constants.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database for scheduled local notifications.
  tz.initializeTimeZones();

  await Future.wait([
    Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
    ),
    NotificationService.instance.initialize(),
  ]);

  runApp(const ProviderScope(child: CrewCommandApp()));
}
