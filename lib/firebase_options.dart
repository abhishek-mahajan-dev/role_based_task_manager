import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAaS746sN6Zmd8bIDc5Hp8ipfZkdVkyPTU',
    appId: '1:1056346182009:web:28101ffa92d073c5c59fa8',
    messagingSenderId: '1056346182009',
    projectId: 'flutter-task-app-e9ec6',
    authDomain: 'flutter-task-app-e9ec6.firebaseapp.com',
    storageBucket: 'flutter-task-app-e9ec6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaFOjSVKHGxMmgc92094PIzsVXdNT-tSE',
    appId: '1:1056346182009:android:840dbeb8444bad72c59fa8',
    messagingSenderId: '1056346182009',
    projectId: 'flutter-task-app-e9ec6',
    storageBucket: 'flutter-task-app-e9ec6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBweaaPsQE0CehYZR_c7229luFiqavH78M',
    appId: '1:1056346182009:ios:e05aaf5b1c70fe3bc59fa8',
    messagingSenderId: '1056346182009',
    projectId: 'flutter-task-app-e9ec6',
    storageBucket: 'flutter-task-app-e9ec6.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBweaaPsQE0CehYZR_c7229luFiqavH78M',
    appId: '1:1056346182009:ios:e05aaf5b1c70fe3bc59fa8',
    messagingSenderId: '1056346182009',
    projectId: 'flutter-task-app-e9ec6',
    storageBucket: 'flutter-task-app-e9ec6.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAaS746sN6Zmd8bIDc5Hp8ipfZkdVkyPTU',
    appId: '1:1056346182009:web:adf26fb45ca1d8b9c59fa8',
    messagingSenderId: '1056346182009',
    projectId: 'flutter-task-app-e9ec6',
    authDomain: 'flutter-task-app-e9ec6.firebaseapp.com',
    storageBucket: 'flutter-task-app-e9ec6.firebasestorage.app',
  );
}
