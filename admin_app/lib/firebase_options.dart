import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptionsAdmin {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('DefaultFirebaseOptionsAdmin have not been configured for web');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('DefaultFirebaseOptionsAdmin have not been configured for iOS');
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        throw UnsupportedError('DefaultFirebaseOptionsAdmin are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZk_ABSOHWK9w_SX_zM09GLKntHMSwhSk',
    appId: '1:241502407227:android:4856ee074522ebb9b9aa1e',
    messagingSenderId: '241502407227',
    projectId: 'pdf-tools-2763d',
    storageBucket: 'pdf-tools-2763d.firebasestorage.app',
  );
}
