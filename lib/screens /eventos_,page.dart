import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  static const grupos = 4, linhas = 20;
  static const wN = 45.0, wNome = 130.0, wDias = 100.0, wPg = 60.0;
  static const hL = 44.0, hH = 36.0;

  late List<List<int>> _dias;
  late List<List<bool>> _pg;
  late List<List<TextEditingController>> _nomes;

  bool _searchOn = false;
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    _dias = List.generate(linhas, (_) => List.generate(grupos, (_) => 0));
    _pg = List.generate(linhas, (_) => List.generate(grupos, (_) => false));
    _nomes = List.generate(
        linhas, (_) => List.generate(grupos, (_) => TextEditingController()));
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    for (final l in _nomes) {
      for (final c in l) {
        c.dispose();
      }
    }
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  void _onSearch() =>
      setState(() => _q = _searchCtrl.text.trim().toLowerCase());

  bool _match(int l, int g) {
    if (_q.isEmpty) return false;
    return _nomes[l][g].text.toLowerCase().contains(_q);
  }

  int _contar() {
    if (_q.isEmpty) return 0;
    int t = 0;
    for (int l = 0; l < linhas; l++) {
      for (int g = 0; g < grupos; g++) {
        if (_match(l, g)) t++;
      }
    }
    return t;
  }

  String _num(int l, int g) =>
      ((g * linhas) + l + 1).toString().padLeft(2, '0');

  void _toggleDia(int l, int g, int bit) {
    if (!AuthStore.instance.podeEditarImportante) return _semPerm();
    setState(() => _dias[l][g] ^= bit);
  }

  void _togglePg(int l, int g) {
    if (!AuthStore.instance.podeEditarImportante) return _semPerm();
    setState(() => _pg[l][g] = !_pg[l][g]);
  }

  void _semPerm() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Apenas administradores podem editar esta tela.'),
      backgroundColor: C.vermelho,
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pode = AuthStore.instance.podeEditarImportante;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: _searchOn
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar nome...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                  border: InputBorder.none,
                ),
              )
            : const Text('EVENTOS',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_searchOn ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                if (_searchOn) {
                  _searchOn = false;
                  _searchCtrl.clear();
                  _q = '';
                } else {
                  _searchOn = true;
                }
              });
            },
          ),
          const BadgeUsuario(),
          const BotaoSalvar(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _aviso(pode),
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
                    children: [
                      _cabecalho(),
                      ...List.generate(linhas, (l) => _linha(l, pode)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aviso(bool pode) {
    if (_q.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: C.amareloClaro,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.amarelo),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: C.azul, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _contar() == 0
                    ? 'Nenhum resultado para "$_q"'
                    : '${_contar()} resultado(s) para "$_q"',
                style: const TextStyle(
                    fontSize: 12,
                    color: C.azul,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: pode ? C.bege : const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(pode ? Icons.info_outline : Icons.lock,
              color: pode ? C.azul : C.vermelho, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pode
                  ? 'Marque os dias (SEX/SÁB/DOM) e o pagamento (PG). Use a lupa para pesquisar.'
                  : 'Somente administradores podem marcar dias/pagamento.',
              style: TextStyle(
                  fontSize: 11,
                  color: pode ? C.azul : C.vermelho,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho() => Container(
        color: C.azulMedio,
        child: Row(
          children: List.generate(
              grupos,
              (g) => Row(
                    children: [
                      _celCab('Nº', wN),
                      _celCab('NOME', wNome),
                      _celCab('DIAS', wDias),
                      _celCab('PG', wPg),
                    ],
                  )),
        ),
      );

  Widget _celCab(String t, double w) => Container(
        width: w,
        height: hH,
        decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Colors.white24))),
        alignment: Alignment.center,
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.3)),
      );

  Widget _linha(int l, bool pode) => Container(
        color: l.isEven ? Colors.white : const Color(0xFFF9FAFB),
        child: Row(
          children: List.generate(
              grupos,
              (g) => Row(
                    children: [
                      _celNum(l, g),
                      _celNome(l, g, pode),
                      _celDias(l, g),
                      _celPg(l, g),
                    ],
                  )),
        ),
      );

  Widget _celNum(int l, int g) => Container(
        width: wN,
        height: hL,
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(color: C.borda),
                bottom: BorderSide(color: C.borda))),
        alignment: Alignment.center,
        child: Text(_num(l, g),
            style: const TextStyle(
                fontSize: 12, color: C.azul, fontWeight: FontWeight.bold)),
      );

  Widget _celNome(int l, int g, bool pode) {
    final dest = _match(l, g);
    return Container(
      width: wNome,
      height: hL,
      decoration: BoxDecoration(
        color: dest ? C.amareloClaro : Colors.transparent,
        border: Border(
          right: const BorderSide(color: C.borda),
          bottom: const BorderSide(color: C.borda),
          top: dest
              ? const BorderSide(color: C.amarelo, width: 2)
              : BorderSide.none,
          left: dest
              ? const BorderSide(color: C.amarelo, width: 2)
              : BorderSide.none,
        ),
      ),
      child: TextField(
        controller: _nomes[l][g],
        textAlign: TextAlign.center,
        readOnly: !pode,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
            fontSize: 11,
            color: pode ? C.azul : C.cinza,
            fontWeight: dest ? FontWeight.bold : FontWeight.normal),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
      ),
    );
  }

  Widget _celDias(int l, int g) => Container(
        width: wDias,
        height: hL,
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(color: C.borda),
                bottom: BorderSide(color: C.borda))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _botaoDia(l, g, 1, 'SEX'),
            const SizedBox(width: 3),
            _botaoDia(l, g, 2, 'SÁB'),
            const SizedBox(width: 3),
            _botaoDia(l, g, 4, 'DOM'),
          ],
        ),
      );

  Widget _botaoDia(int l, int g, int bit, String label) {
    final ativo = (_dias[l][g] & bit) != 0;
    return GestureDetector(
      onTap: () => _toggleDia(l, g, bit),
      child: Container(
        width: 28,
        height: 30,
        decoration: BoxDecoration(
          color: ativo ? C.verde : const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: ativo ? C.verde : C.borda),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                fontSize: 9,
                color: ativo ? Colors.white : C.azul,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _celPg(int l, int g) {
    final pago = _pg[l][g];
    return Container(
      width: wPg,
      height: hL,
      decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(color: C.borda),
              bottom: BorderSide(color: C.borda))),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _togglePg(l, g),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: pago ? C.verde : const Color(0xFFFFE0E0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: pago ? C.verde : Colors.red.shade300),
          ),
          child: Text(
            pago ? 'PAGO' : 'N/PG',
            style: TextStyle(
                fontSize: 9,
                color: pago ? Colors.white : Colors.red.shade700,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
