import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } else {
      return web;
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: "AIzaSyCp_mY3JkdQefl8V46MLtJjP3Pv2RjF0Xg",
    authDomain: "commerce-f8f52.firebaseapp.com",
    projectId: "commerce-f8f52",
    storageBucket: "commerce-f8f52.appspot.com",
    messagingSenderId: "1098962927264",
    appId: "1:1098962927264:android:09e41aa35a68956fb413c5",
    measurementId: "G-FSZEP417KM",
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: "AIzaSyCp_mY3JkdQefl8V46MLtJjP3Pv2RjF0Xg",
    authDomain: "commerce-f8f52.firebaseapp.com",
    projectId: "commerce-f8f52",
    storageBucket: "commerce-f8f52.appspot.com",
    messagingSenderId: "1098962927264",
    appId: "1:1098962927264:ios:09e41aa35a68956fb413c5",
    measurementId: "G-FSZEP417KM",
  );

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: "AIzaSyCp_mY3JkdQefl8V46MLtJjP3Pv2RjF0Xg",
    authDomain: "commerce-f8f52.firebaseapp.com",
    projectId: "commerce-f8f52",
    storageBucket: "commerce-f8f52.appspot.com",
    messagingSenderId: "1098962927264",
    appId: "1:1098962927264:web:09e41aa35a68956fb413c5",
    measurementId: "G-FSZEP417KM",
  );
}
