import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import '../services/designacao_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';

class S13Page extends StatefulWidget {
  const S13Page({super.key});

  @override
  State<S13Page> createState() => _S13PageState();
}

class _S13PageState extends State<S13Page> {
  static const linhas = 20, blocos = 4;
  static const hH1 = 30.0, hH2 = 42.0, hL = 74.0;
  static const wT = 60.0, wU = 120.0, wD = 100.0;
  static const wB = wD * 2;

  final _ano = TextEditingController();
  final List<TextEditingController> _terr =
      List.generate(linhas, (_) => TextEditingController());
  final List<TextEditingController> _ult =
      List.generate(linhas, (_) => TextEditingController());
  final List<List<List<TextEditingController>>> _blocos = List.generate(
    linhas,
    (_) => List.generate(blocos,
        (_) => List.generate(3, (_) => TextEditingController())),
  );

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    DesignacaoStore.instance.addListener(_sinc);
    _sinc();
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    DesignacaoStore.instance.removeListener(_sinc);
    _ano.dispose();
    for (final c in _terr) {
      c.dispose();
    }
    for (final c in _ult) {
      c.dispose();
    }
    for (final l in _blocos) {
      for (final b in l) {
        for (final c in b) {
          c.dispose();
        }
      }
    }
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  void _sinc() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < linhas; i++) {
        final t = 'T-${i + 1}';
        if (_terr[i].text != t) _terr[i].text = t;
        final u = DesignacaoStore.instance.ultimaDataConclusao(t);
        if (_ult[i].text != u) _ult[i].text = u;
        for (int b = 0; b < blocos; b++) {
          final d = DesignacaoStore.instance.get(t, b);
          if (_blocos[i][b][0].text != d.nome) {
            _blocos[i][b][0].text = d.nome;
          }
          if (_blocos[i][b][1].text != d.dataDesignacao) {
            _blocos[i][b][1].text = d.dataDesignacao;
          }
          if (_blocos[i][b][2].text != d.dataConclusao) {
            _blocos[i][b][2].text = d.dataConclusao;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pode = AuthStore.instance.podeEditarImportante;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('S.13 — REGISTRO DE DESIGNAÇÃO',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
              const Center(
                child: Text('REGISTRO DE DESIGNAÇÃO DE TERRITÓRIO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3)),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: C.bege, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.link, color: C.azul, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Preenchido automaticamente pela aba TERRITÓRIOS',
                        style: TextStyle(
                            fontSize: 10,
                            color: C.azul,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Ano de Serviço: ',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _ano,
                      readOnly: !pode,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      ...List.generate(linhas, (i) => _row(i)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '*Ao iniciar uma nova folha, use esta coluna para registrar a data em que cada território foi concluído pela última vez.',
                style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              const Text('S-13-T 01/22', style: TextStyle(fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hCell('Terr.\nn.º', wT, hH1 + hH2),
        _hCell('Última data\nconcluída*', wU, hH1 + hH2),
        ...List.generate(blocos, (i) {
          return SizedBox(
            width: wB,
            child: Column(
              children: [
                _hCell('Designado para', wB, hH1),
                Row(
                  children: [
                    _hCell('Data da\ndesignação', wD, hH2),
                    _hCell('Data da\nconclusão', wD, hH2),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _hCell(String t, double w, double h) => Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
          color: C.cinzaForm,
          border: Border(
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black)),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      );

  Widget _row(int i) => Row(
        children: [
          _cell(_terr[i], wT, hL),
          _cell(_ult[i], wU, hL,
              fundo: const Color(0xFFFFF7DC), negrito: true),
          ...List.generate(blocos, (b) => _bloco(i, b)),
        ],
      );

  Widget _bloco(int i, int b) => Container(
        width: wB,
        height: hL,
        decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black)),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black))),
                child: _autoConteudo(_blocos[i][b][0]),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Colors.black))),
                      child: _autoConteudo(_blocos[i][b][1]),
                    ),
                  ),
                  Expanded(child: _autoConteudo(_blocos[i][b][2])),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _cell(TextEditingController c, double w, double h,
      {Color? fundo, bool negrito = false}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: fundo,
        border: const Border(
            right: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: c,
        builder: (_, __) => Text(
          c.text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: negrito ? FontWeight.bold : FontWeight.w500),
        ),
      ),
    );
  }

  Widget _autoConteudo(TextEditingController c) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          c.text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 11, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
