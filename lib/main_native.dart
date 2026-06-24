import 'package:flutter/material.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/auth/supabase_auth_manager.dart';
import 'package:thix_id/core/auth/token_service.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/supabase/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseConfig.initialize();
  } catch (_) {
    // Keep startup resilient in temporary compile-safe mode.
  }

  final auth = AuthController(auth: SupabaseAuthManager());
  try {
    await auth.init();
  } catch (_) {
    // Keep startup resilient in temporary compile-safe mode.
  }

  try {
    await TokenService.getToken();
  } catch (_) {
    // Token bootstrap failures should not prevent app startup.
  }

  runApp(MyApp(auth: auth));
}

class MyApp extends StatelessWidget {
  final AuthController auth;

  const MyApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.create(auth);

    return MaterialApp.router(
      title: 'THIX ID',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7EA4)),
        useMaterial3: true,
      ),
    );
  }
}
