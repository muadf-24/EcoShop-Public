import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCaUFf1zyv-shYswlhj2cNHphkoZhWu-nY',
    appId: '1:794359593826:web:52108c4fac5b9ed9ec4a3b',
    messagingSenderId: '794359593826',
    projectId: 'ecoshop-store-2026',
    authDomain: 'ecoshop-store-2026.firebaseapp.com',
    storageBucket: 'ecoshop-store-2026.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYJvMP6tE9OsZre9uhyKD25JQPQ4Y8ssE',
    appId: '1:794359593826:ios:d49db21da5429cfbec4a3b',
    messagingSenderId: '794359593826',
    projectId: 'ecoshop-store-2026',
    storageBucket: 'ecoshop-store-2026.firebasestorage.app',
    iosBundleId: 'com.example.ecoshop',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYJvMP6tE9OsZre9uhyKD25JQPQ4Y8ssE',
    appId: '1:794359593826:ios:d49db21da5429cfbec4a3b',
    messagingSenderId: '794359593826',
    projectId: 'ecoshop-store-2026',
    storageBucket: 'ecoshop-store-2026.firebasestorage.app',
    iosBundleId: 'com.example.ecoshop',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsTa4CS-KEFwymacCyybsfgK_I5WrFfQE',
    appId: '1:794359593826:android:fd284951911dd341ec4a3b',
    messagingSenderId: '794359593826',
    projectId: 'ecoshop-store-2026',
    storageBucket: 'ecoshop-store-2026.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCaUFf1zyv-shYswlhj2cNHphkoZhWu-nY',
    appId: '1:794359593826:web:69a39647e85bffacec4a3b',
    messagingSenderId: '794359593826',
    projectId: 'ecoshop-store-2026',
    authDomain: 'ecoshop-store-2026.firebaseapp.com',
    storageBucket: 'ecoshop-store-2026.firebasestorage.app',
  );

}