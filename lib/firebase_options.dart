// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAgOLCg0Ud5OmcTJmznN8NNDig5LPoIPNE',
    appId: '1:429842834488:web:4abd318e7b951214e2b2cd',
    messagingSenderId: '429842834488',
    projectId: 'reddam-cce',
    authDomain: 'reddam-cce.firebaseapp.com',
    storageBucket: 'reddam-cce.appspot.com',
    measurementId: 'G-E64SHJYTGR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6ld8EwVIRffOEalcahTdT77mu_qtQar0',
    appId: '1:429842834488:android:16928320b9b4a151e2b2cd',
    messagingSenderId: '429842834488',
    projectId: 'reddam-cce',
    storageBucket: 'reddam-cce.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZuXJOQwXnL9vd5g2Uq7s9Idvn2T_6_qo',
    appId: '1:429842834488:ios:87906907815fee7ee2b2cd',
    messagingSenderId: '429842834488',
    projectId: 'reddam-cce',
    storageBucket: 'reddam-cce.appspot.com',
    iosClientId: '429842834488-ru2nmargcntfd9liim64n8pbj7n69j4t.apps.googleusercontent.com',
    iosBundleId: 'com.example.cceProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCZuXJOQwXnL9vd5g2Uq7s9Idvn2T_6_qo',
    appId: '1:429842834488:ios:87906907815fee7ee2b2cd',
    messagingSenderId: '429842834488',
    projectId: 'reddam-cce',
    storageBucket: 'reddam-cce.appspot.com',
    iosClientId: '429842834488-ru2nmargcntfd9liim64n8pbj7n69j4t.apps.googleusercontent.com',
    iosBundleId: 'com.example.cceProject',
  );
}