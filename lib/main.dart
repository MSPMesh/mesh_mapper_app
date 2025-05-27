import 'package:flutter/material.dart';
import 'pages/map_page.dart';
import 'pages/settings_page.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSM Map App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MapPage(),
      routes: {
        '/settings': (context) => const SettingsPage(), // Add route
      },
    );
  }
}
