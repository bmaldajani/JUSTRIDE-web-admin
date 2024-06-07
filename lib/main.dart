import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: "AIzaSyA_sTtV6ofRWBtcvLrWYURwaGAeZnloGzk",
      authDomain: "scooterrentalapplication.firebaseapp.com",
      projectId: "scooterrentalapplication",
     storageBucket: "scooterrentalapplication.appspot.com",
     messagingSenderId: "279262660937",
    appId: "1:279262660937:web:d9bf1197ff5ffea06cf298",
     measurementId: "G-7YMESLXCYF"
    ),
  );
  Environment.init(
    apiBaseUrl: 'https://example.com',
  );

  runApp(const RootApp());
}

