import 'package:flutter/material.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';
import 'detalhe_territorio_page.dart';

class TerritoriosPage extends StatelessWidget {
  const TerritoriosPage({super.key});

  static const List<Map<String, String>> territorios = [
    {'numero': 'T-1', 'nome': 'St Terezinha 1'},
    {'numero': 'T-2', 'nome': 'St Terezinha 2'},
    {'numero': 'T-3', 'nome': 'Fantinato 1'},
    {'numero': 'T-4', 'nome': 'Fantinato 2'},
    {'numero': 'T-5', 'nome': 'Fantinato 3'},
    {'numero': 'T-6', 'nome': 'Jd Vitória'},
    {'numero': 'T-7', 'nome': 'Chaparral 1'},
    {'numero': 'T-8', 'nome': 'Chaparral 2'},
    {'numero': 'T-9', 'nome': 'Centro'},
    {'numero': 'T-10', 'nome': 'Vila Nova'},
    {'numero': 'T-11', 'nome': 'Boa Esperança'},
    {'numero': 'T-12', 'nome': 'Santa Rita'},
    {'numero': 'T-13', 'nome': 'São José'},
    {'numero': 'T-14', 'nome': 'Ipê Amarelo'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TERRITÓRIOS DA CONGREGAÇÃO',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5),
        ),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: territorios.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final t = territorios[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalheTerritorioPage(
                      numero: t['numero']!,
                      nome: t['nome']!,
                    ),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: C.azul, size: 38),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${t['numero']} ${t['nome']}',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: C.azul),
                        ),
                      ),
                      const Icon(Icons.play_arrow,
                          color: C.amarelo, size: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
