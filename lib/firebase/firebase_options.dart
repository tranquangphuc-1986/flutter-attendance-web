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
    apiKey: 'AIzaSyAsSvwPv0qbykHVSvddDbiA8VuzDvCrWUA',
    appId: '1:209172920439:web:3d40ed02ba3606c9c8ae72',
    messagingSenderId: '209172920439',
    projectId: 'quankien-ede9b',
    authDomain: 'quankien-ede9b.firebaseapp.com',
    storageBucket: 'quankien-ede9b.firebasestorage.app',
    measurementId: 'G-DLNRLPH7VY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLJzCQ8xYeOtGCBuvMO2DhE1cF4SI3D6w',
    appId: '1:209172920439:android:7b4b1edf72c5ea5cc8ae72',
    messagingSenderId: '209172920439',
    projectId: 'quankien-ede9b',
    storageBucket: 'quankien-ede9b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9RTnak0rQ_l9adDRNvL0ym0FmHe51qGA',
    appId: '1:209172920439:ios:3ebe58536bb6edaac8ae72',
    messagingSenderId: '209172920439',
    projectId: 'quankien-ede9b',
    storageBucket: 'quankien-ede9b.firebasestorage.app',
    iosBundleId: 'com.example.app02',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA9RTnak0rQ_l9adDRNvL0ym0FmHe51qGA',
    appId: '1:209172920439:ios:3ebe58536bb6edaac8ae72',
    messagingSenderId: '209172920439',
    projectId: 'quankien-ede9b',
    storageBucket: 'quankien-ede9b.firebasestorage.app',
    iosBundleId: 'com.example.app02',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAsSvwPv0qbykHVSvddDbiA8VuzDvCrWUA',
    appId: '1:209172920439:web:f61dea62093cf238c8ae72',
    messagingSenderId: '209172920439',
    projectId: 'quankien-ede9b',
    authDomain: 'quankien-ede9b.firebaseapp.com',
    storageBucket: 'quankien-ede9b.firebasestorage.app',
    measurementId: 'G-XGVH049LCC',
  );
}
