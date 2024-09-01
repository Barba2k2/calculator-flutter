import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Calculadora Simples',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  String display = '0';
  List<String> history = [];
  bool newCalculation = false;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-7278601840642594/3511156243',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          log('Failed to load a banner ad: ${error.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  void onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        display = '0';
      } else if (text == '⌫') {
        display =
            display.length > 1 ? display.substring(0, display.length - 1) : '0';
      } else if (text == '=') {
        try {
          Parser parser = Parser();
          Expression exp = parser.parse(display.replaceAll('x', '*'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          setState(() {
            history.add('$display = ${eval.toString()}');
          });
          display = eval.toString();
          newCalculation = true;
        } catch (e) {
          display = 'Erro';
          newCalculation = true;
        }
      } else {
        if (newCalculation && '0123456789'.contains(text)) {
          display = text;
          newCalculation = false;
        } else if (newCalculation && !'0123456789'.contains(text)) {
          display += text;
          newCalculation = false;
        } else if (display == '0' && text != '.') {
          display = text;
        } else {
          display += text;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actionsIconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: history.reversed.map(
            (entry) {
              var parts = entry.split(' = ');
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 20.0),
                      child: Column(
                        children: [
                          Text(
                            parts[0],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            parts[1],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.grey[800],
                      thickness: 1,
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isBannerAdReady)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: SizedBox(
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Text(
                display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildButtonRow(['C', '⌫', '/', '*'], isSecondary: true),
            buildButtonRow(['7', '8', '9', '-']),
            buildButtonRow(['4', '5', '6', '+']),
            buildButtonRow(['1', '2', '3', '=']),
            buildButtonRow(['0', '.', '', ''], isLastRow: true),
          ],
        ),
      ),
    );
  }

  Widget buildButtonRow(
    List<String> buttons, {
    bool isSecondary = false,
    bool isLastRow = false,
  }) {
    return Padding(
      padding: isLastRow
          ? const EdgeInsets.symmetric(vertical: 10)
          : const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons.map(
          (text) {
            if (text.isEmpty) {
              return const Expanded(
                child: SizedBox(),
              );
            }

            return buildButton(
              text,
              isSecondary: isSecondary,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget buildButton(String text, {bool isSecondary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            onPressed: () => onButtonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSecondary ? Colors.grey[850] : Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: isSecondary ? Colors.blue : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
