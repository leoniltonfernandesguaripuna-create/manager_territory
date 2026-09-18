import 'package:flutter/material.dart';
import 'cores.dart';
import 'widgets.dart';

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
          backgroundColor: C.azul,
          title: const Text('Teste'),
          actions: const [BadgeUsuario(), BotaoSalvar()],
        ),
        body: const Center(child: Text('Estrutura OK!')),
      ),
    );
  }
}
