import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main.dart' as app;
import 'core/config/environment_config.dart';

/// EcoShop Production Environment Entry Point
/// This is the PRODUCTION entry point - All debugging disabled

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set production environment
  EnvironmentConfig.setEnvironment(Environment.production);

  // Disable debug prints in production
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialize Firebase with production configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Production-only logging (minimal)
  if (kDebugMode) {
    debugPrint('⚠️ WARNING: Running production build in debug mode');
  }

  // Run the main app
  app.main();
}
