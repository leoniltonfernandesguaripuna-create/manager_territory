
import 'package:flutter/material.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Teste'),
          backgroundColor: const Color(0xFF1A365D),
        ),
        body: const Center(
          child: Text('Funcionou!'),
        ),
      ),
    );
  }
}
