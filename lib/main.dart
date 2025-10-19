import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/common/myhttp.dart';
import 'package:movie_app/common/utils.dart';
import 'package:movie_app/firebase_options.dart';
import 'package:movie_app/services/chatbot.dart';
import 'package:movie_app/widgets/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // inicializa o serviço do Firebase AI (Gemini)
  await FirebaseAIService.initialize();

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: kBackgoundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: kBackgoundColor,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: kBackgoundColor,
          )),
      home: const BottomNavBar(),
    );
  }
}
