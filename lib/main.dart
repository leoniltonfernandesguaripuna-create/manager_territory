import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const TerritoryManagerApp());
}

class TerritoryManagerApp extends StatelessWidget {
  const TerritoryManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Territory Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A365D),
          brightness: Brightness.light,
        ),
      ),
      home: HomePage(),
    );
  }
}
