import 'package:flutter/material.dart';
import '../models/designacao.dart';
import '../services/auth_store.dart';
import '../services/designacao_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';

class DetalheTerritorioPage extends StatefulWidget {
  final String numero;
  final String nome;

  const DetalheTerritorioPage({
    super.key,
    required this.numero,
    required this.nome,
  });

  @override
  State<DetalheTerritorioPage> createState() => _DetalheTerritorioPageState();
}

class _DetalheTerritorioPageState extends State<DetalheTerritorioPage> {
  String? _fotoMapa;

  final List<List<int>> _quadrasEstados =
      List.generate(10, (_) => List.generate(14, (_) => 0));

  final List<String> _cabecalhoDirigente = [
    'DIRIGENTE', 'PUBLI', 'DATA',
    'DIRIGENTE', 'PUBLI', 'DATA',
    'DIRIGENTE', 'PUBLI', 'DATA',
    'DATA INICIAL', 'DATA FINAL',
  ];

  final List<List<TextEditingController>> _dirigenteControllers =
      List.generate(11, (_) => List.generate(11, (_) => TextEditingController()));

  static const int colDirigente = 0;
  static const int colDataInicial = 9;
  static const int colDataFinal = 10;

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    for (int linha = 1; linha <= 4; linha++) {
      _dirigenteControllers[linha][colDirigente].addListener(_rebuild);
      _dirigenteControllers[linha][colDataInicial].addListener(_rebuild);
      _dirigenteControllers[linha][colDataFinal].addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    for (final l in _dirigenteControllers) {
      for (final c in l) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  void _rebuild() {
    final lista = <Designacao>[];
    for (int linha = 1; linha <= 4; linha++) {
      final nome = _dirigenteControllers[linha][colDirigente].text.trim();
      final dataIni =
          _dirigenteControllers[linha][colDataInicial].text.trim();
      final dataFim = _dirigenteControllers[linha][colDataFinal].text.trim();

      if (nome.isNotEmpty && dataIni.isNotEmpty) {
        lista.add(Designacao(
            nome: nome, dataDesignacao: dataIni, dataConclusao: dataFim));
      } else if (dataFim.isNotEmpty) {
        for (int i = lista.length - 1; i >= 0; i--) {
          if (lista[i].dataConclusao.isEmpty) {
            lista[i].dataConclusao = dataFim;
            break;
          }
        }
      }
    }
    DesignacaoStore.instance.setAll(widget.numero, lista);
  }

  void _toggle(int l, int c) {
    setState(() {
      _quadrasEstados[l][c] = (_quadrasEstados[l][c] + 1) % 3;
    });
  }

  Color _cor(int e) {
    switch (e) {
      case 1:
        return const Color(0xFFFFEB99);
      case 2:
        return const Color(0xFFA8D5A8);
      default:
        return Colors.white;
    }
  }

  void _fotoOpcoes() {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas administradores podem alterar a foto do mapa.'),
          backgroundColor: C.vermelho,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: C.cinza,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Foto do mapa',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: C.azul)),
              const SizedBox(height: 20),
              _opcao(Icons.photo_library_outlined, 'Escolher da galeria', () {
                Navigator.pop(ctx);
                setState(() => _fotoMapa =
                    'https://picsum.photos/seed/${widget.numero}/600/500');
              }),
              const SizedBox(height: 8),
              _opcao(Icons.camera_alt_outlined, 'Tirar foto', () {
                Navigator.pop(ctx);
                setState(() => _fotoMapa =
                    'https://picsum.photos/seed/${widget.numero}/600/500');
              }),
              if (_fotoMapa != null) ...[
                const SizedBox(height: 8),
                _opcao(Icons.delete_outline, 'Remover foto', () {
                  Navigator.pop(ctx);
                  setState(() => _fotoMapa = null);
                }, cor: Colors.red),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcao(IconData icon, String label, VoidCallback onTap, {Color? cor}) {
    return Material(
      color: C.bege,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: cor ?? C.azul, size: 22),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cor ?? C.azul)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.numero,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cardNome(),
              const SizedBox(height: 16),
              _areaFoto(),
              const SizedBox(height: 12),
              _botaoFoto(),
              const SizedBox(height: 24),
              _titulo('DIRIGENTE'),
              const SizedBox(height: 8),
              _info(),
              const SizedBox(height: 8),
              _gradeDirigente(),
              const SizedBox(height: 24),
              _titulo('QUADRAS TRABALHADAS'),
              const SizedBox(height: 8),
              _legenda(),
              const SizedBox(height: 8),
              _gradeQuadras(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardNome() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.map, color: C.azul, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${widget.numero} ${widget.nome}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: C.azul),
              ),
            ),
          ],
        ),
      );

  Widget _areaFoto() => Container(
        height: 240,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: _fotoMapa != null
            ? Image.network(_fotoMapa!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined,
                      size: 60, color: C.cinza.withOpacity(0.6)),
                  const SizedBox(height: 10),
                  const Text('Nenhuma foto do mapa',
                      style: TextStyle(fontSize: 13, color: C.cinza)),
                ],
              ),
      );

  Widget _botaoFoto() => SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _fotoOpcoes,
          icon: Icon(
              _fotoMapa != null ? Icons.edit : Icons.add_a_photo_outlined,
              size: 18),
          label: Text(
            _fotoMapa != null ? 'Alterar foto do mapa' : 'Adicionar foto do mapa',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: C.azul,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  Widget _titulo(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: C.azul, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.table_chart_outlined,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(t,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5)),
          ],
        ),
      );

  Widget _info() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: C.bege, borderRadius: BorderRadius.circular(8)),
        child: const Row(
          children: [
            Icon(Icons.link, color: C.azul, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quem INICIA (nome + data inicial) cria um bloco novo. Quem CONCLUI só preenche a data final.',
                style: TextStyle(
                    fontSize: 11,
                    color: C.azul,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

  Widget _legenda() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.borda),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _leg(Colors.white, 'Vazio'),
            _leg(const Color(0xFFFFEB99), '1 toque'),
            _leg(const Color(0xFFA8D5A8), '2 toques'),
          ],
        ),
      );

  Widget _leg(Color cor, String t) => Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
                color: cor,
                border: Border.all(color: C.borda),
                borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 6),
          Text(t,
              style: const TextStyle(
                  fontSize: 11,
                  color: C.azul,
                  fontWeight: FontWeight.w600)),
        ],
      );

  Widget _gradeDirigente() {
    const w = 100.0, h = 44.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(11, (linha) {
            return Row(
              children: List.generate(11, (coluna) {
                if (linha == 0) {
                  return Container(
                    width: w,
                    height: h,
                    decoration: const BoxDecoration(
                      color: C.azulMedio,
                      border: Border(right: BorderSide(color: Colors.white24)),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(_cabecalhoDirigente[coluna],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  );
                }
                final dest = (coluna == colDirigente ||
                        coluna == colDataInicial ||
                        coluna == colDataFinal) &&
                    linha <= 4;
                return Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: dest ? const Color(0xFFFFF7DC) : Colors.white,
                    border: const Border(
                        right: BorderSide(color: C.borda),
                        bottom: BorderSide(color: C.borda)),
                  ),
                  child: TextField(
                    controller: _dirigenteControllers[linha][coluna],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: C.azul),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _gradeQuadras() {
    const w = 60.0, h = 44.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(11, (linha) {
            return Row(
              children: List.generate(14, (coluna) {
                if (linha == 0) {
                  final num = (coluna + 1).toString().padLeft(2, '0');
                  return Container(
                    width: w,
                    height: h,
                    decoration: const BoxDecoration(
                      color: C.azulMedio,
                      border: Border(right: BorderSide(color: Colors.white24)),
                    ),
                    alignment: Alignment.center,
                    child: Text(num,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  );
                }
                final e = _quadrasEstados[linha - 1][coluna];
                return GestureDetector(
                  onTap: () => _toggle(linha - 1, coluna),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: _cor(e),
                      border: const Border(
                          right: BorderSide(color: C.borda),
                          bottom: BorderSide(color: C.borda)),
                    ),
                    alignment: Alignment.center,
                    child: e == 0
                        ? null
                        : Icon(e == 1 ? Icons.edit : Icons.check,
                            size: 18,
                            color: e == 1
                                ? C.amarelo
                                : const Color(0xFF2F855A)),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
