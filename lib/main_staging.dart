import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main.dart' as app;
import 'core/config/environment_config.dart';

/// EcoShop Staging Environment Entry Point
/// This file configures the app for the staging environment with test data and debugging enabled

void main() async {
  // MUST BE FIRST - Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Set staging environment
  EnvironmentConfig.setEnvironment(Environment.staging);

  try {
    // Initialize Firebase with staging configuration - Prevent double initialization
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Firebase initialization timeout on Web platform');
        },
      );
      debugPrint('✅ Firebase initialized successfully');
      debugPrint('✅ Firebase apps count: ${Firebase.apps.length}');
    } else {
      debugPrint('⚠️ Firebase already initialized, skipping...');
    }

    // Enable debug mode for staging
    debugPrint('🚀 EcoShop Staging Environment Started');
    debugPrint('📱 Environment: ${EnvironmentConfig.currentEnvironment.name}');
    debugPrint('🌐 API Base URL: ${EnvironmentConfig.apiBaseUrl}');
    debugPrint('🔥 Firebase Project: staging-ecoshop');

    // Run the main app
    app.main();
  } catch (e, stackTrace) {
    debugPrint('❌ FATAL: Firebase initialization failed on Web');
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');
    
    // Fallback: Run app without Firebase (graceful degradation)
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Initialization Failed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $e',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Please ensure:\n• Firebase is properly configured\n• Web SDK scripts are loaded\n• Internet connection is active',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
