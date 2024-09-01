import 'package:calculator/firebase_options.dart';
import 'package:calculator/pages/calculator_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  MobileAds.instance.initialize();
  runApp(
    const CalculadoraSimples(),
  );
}

class CalculadoraSimples extends StatelessWidget {
  const CalculadoraSimples({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const CalculadoraPage(),
    );
  }
}
