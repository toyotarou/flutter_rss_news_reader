import 'package:flutter/material.dart';
import 'package:flutter_rss_news_reader/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark), fontFamily: 'KiwiMaru'),
      themeMode: ThemeMode.dark,
      title: 'rss news reader',

      home: HomeScreen(),
    );
  }
}
