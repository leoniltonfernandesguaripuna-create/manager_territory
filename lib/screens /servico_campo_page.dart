import 'package:flutter/material.dart';
import '../models/linha_servico.dart';
import '../services/auth_store.dart';
import '../services/dirigentes_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';

class ServicoCampoPage extends StatefulWidget {
  const ServicoCampoPage({super.key});

  @override
  State<ServicoCampoPage> createState() => _ServicoCampoPageState();
}

class _ServicoCampoPageState extends State<ServicoCampoPage> {
  static const wMes = 65.0,
      wSemana = 80.0,
      wLocal = 130.0,
      wHorario = 75.0,
      wDirigente = 150.0,
      h = 44.0;

  static const meses = [
    'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
    'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO',
  ];

  int _ano = 2025, _mes = 9;
  late List<LinhaServico> _linhas;

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    _linhas = _gerar(_ano, _mes);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  List<LinhaServico> _gerar(int ano, int mes) {
    final linhas = <LinhaServico>[];
    const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    int iSeg = 0, iSab = 0, iDom = 0;
    final ultimoDia = DateTime(ano, mes + 1, 0).day;

    for (int d = 1; d <= ultimoDia; d++) {
      final data = DateTime(ano, mes, d);
      final ds = data.weekday;

      String horario = '08:30';
      if (ds == DateTime.thursday) horario = '17:30';
      if (ano >= 2026 && ds == DateTime.wednesday) horario = '17:30';

      String dirigente = '';
      if (ds >= 1 && ds <= 5) {
        final l = DirigentesStore.validos(0);
        if (l.isNotEmpty) {
          dirigente = l[iSeg % l.length];
          iSeg++;
        }
      } else if (ds == 6) {
        final l = DirigentesStore.validos(1);
        if (l.isNotEmpty) {
          dirigente = l[iSab % l.length];
          iSab++;
        }
      } else {
        final l = [
          ...DirigentesStore.validos(1),
          ...DirigentesStore.validos(2)
        ];
        if (l.isNotEmpty) {
          dirigente = l[iDom % l.length];
          iDom++;
        }
      }

      linhas.add(LinhaServico(
        mes: '${d.toString().padLeft(2, '0')}/${mes.toString().padLeft(2, '0')}',
        semana: nomes[ds - 1],
        horario: horario,
        dirigente: dirigente,
      ));
    }
    return linhas;
  }

  void _mudarMes(int delta) {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas administradores podem trocar o mês.'),
          backgroundColor: C.vermelho,
        ),
      );
      return;
    }
    setState(() {
      int nm = _mes + delta, na = _ano;
      if (nm < 1) {
        nm = 12;
        na--;
      } else if (nm > 12) {
        nm = 1;
        na++;
      }
      _mes = nm;
      _ano = na;
      _linhas = _gerar(_ano, _mes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nomeMes = meses[_mes - 1];
    final pode = AuthStore.instance.podeEditarImportante;

    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('SERVIÇO DE CAMPO',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: C.borda),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _mudarMes(-1),
                      icon: Icon(Icons.chevron_left,
                          color: pode ? C.azul : C.cinza),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$nomeMes $_ano',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: C.azul,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _mudarMes(1),
                      icon: Icon(Icons.chevron_right,
                          color: pode ? C.azul : C.cinza),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            ? 'Dirigentes atribuídos automaticamente pela aba DIRIGENTE.'
                            : 'Somente administradores podem editar esta tela.',
                        style: TextStyle(
                            fontSize: 11,
                            color: pode ? C.azul : C.vermelho,
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.borda),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabecalho(),
                      ...List.generate(
                          _linhas.length, (i) => _linha(i, _linhas[i], pode)),
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

  Widget _cabecalho() => Container(
        color: C.azulMedio,
        child: Row(
          children: [
            _celCab('MÊS', wMes),
            _celCab('SEMANA', wSemana),
            _celCab('LOCAL', wLocal),
            _celCab('HORÁRIO', wHorario),
            _celCab('DIRIGENTE', wDirigente),
          ],
        ),
      );

  Widget _celCab(String t, double w) => Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Colors.white24))),
        alignment: Alignment.center,
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      );

  Widget _linha(int i, LinhaServico l, bool pode) {
    return Container(
      color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
      child: Row(
        children: [
          _celTexto(l.mes, wMes, bold: true),
          _celTexto(l.semana, wSemana),
          _celEdit(l.local, wLocal, 'Local', (v) => l.local = v, pode),
          _celHorario(l.horario, wHorario),
          _celDirigente(l.dirigente, wDirigente),
        ],
      ),
    );
  }

  Widget _celTexto(String t, double w, {bool bold = false}) => Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(color: C.borda),
                bottom: BorderSide(color: C.borda))),
        alignment: Alignment.center,
        child: Text(t,
            style: TextStyle(
                fontSize: 12,
                color: C.azul,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
      );

  Widget _celHorario(String horario, double w) {
    final tarde = horario == '17:30';
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(color: C.borda),
              bottom: BorderSide(color: C.borda))),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: tarde ? C.bege : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(horario,
            style: const TextStyle(
                fontSize: 12, color: C.azul, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _celEdit(String valor, double w, String hint,
      ValueChanged<String> onChanged, bool pode) {
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(color: C.borda),
              bottom: BorderSide(color: C.borda))),
      child: TextField(
        controller: TextEditingController(text: valor),
        onChanged: pode ? onChanged : null,
        readOnly: !pode,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: pode ? C.azul : C.cinza),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: C.cinza),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
      ),
    );
  }

  Widget _celDirigente(String nome, double w) {
    final vazio = nome.isEmpty;
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
          border: Border(
              right: BorderSide(color: C.borda),
              bottom: BorderSide(color: C.borda))),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        vazio ? '—' : nome,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 11,
            color: vazio ? C.cinza : C.azul,
            fontWeight: vazio ? FontWeight.normal : FontWeight.w600),
      ),
    );
  }
}
