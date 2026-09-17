import 'package:flutter/material.dart';
import '../services/dirigentes_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';

class DirigentePage extends StatefulWidget {
  const DirigentePage({super.key});

  @override
  State<DirigentePage> createState() => _DirigentePageState();
}

class _DirigentePageState extends State<DirigentePage> {
  static const total = 21;
  static const cols = 3;

  final List<List<TextEditingController>> _controllers = List.generate(
    total,
    (_) => List.generate(cols, (_) => TextEditingController()),
  );

  final cabecalho = ['SEGUNDA A SEXTA', 'SÁBADO', 'DOMINGO'];

  @override
  void initState() {
    super.initState();
    for (int c = 0; c < cols; c++) {
      final lista = DirigentesStore.nomes[c];
      for (int i = 0; i < lista.length && i < (total - 1); i++) {
        _controllers[i + 1][c].text = lista[i];
      }
    }
  }

  @override
  void dispose() {
    for (final l in _controllers) {
      for (final c in l) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _atualizar(int linha, int col, String v) {
    DirigentesStore.setAt(col, linha - 1, v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('DIRIGENTE',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    color: C.azul,
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.table_chart_outlined,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('GRADE DE DIRIGENTES',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: C.bege, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: C.azul, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seg-Sex → dirigem de seg a sex | Sábado → sáb e dom | Domingo → só dom',
                        style: TextStyle(
                            fontSize: 11,
                            color: C.azul,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.borda),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: List.generate(total, (linha) {
                      return Row(
                        children: List.generate(cols, (col) {
                          if (linha == 0) {
                            return Container(
                              width: 140,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: C.azulMedio,
                                border: Border(
                                    right: BorderSide(color: Colors.white24),
                                    bottom: BorderSide(color: C.azul)),
                              ),
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(cabecalho[col],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            );
                          }
                          return Container(
                            width: 140,
                            height: 50,
                            decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(color: C.borda),
                                  bottom: BorderSide(color: C.borda)),
                            ),
                            child: TextField(
                              controller: _controllers[linha][col],
                              textAlign: TextAlign.center,
                              onChanged: (v) => _atualizar(linha, col, v),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: C.azul,
                                  fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 14),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
