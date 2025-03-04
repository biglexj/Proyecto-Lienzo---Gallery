import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'home/home_screen.dart';

void main() {
  devtools.log('App started');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    devtools.log('Building MyApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galería',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
