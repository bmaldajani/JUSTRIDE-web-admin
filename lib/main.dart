import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyALIFzCQ0Zv-YblJheZWkfDBni6GCw28oA",
          projectId: "justride-116a0",
          messagingSenderId: "434330513806",
          appId: "1:434330513806:web:a6fefdbc78301026a0b4df"));
  Environment.init(
    apiBaseUrl: 'https://example.com',
  );

  runApp(const RootApp());
}
