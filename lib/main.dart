// ============== SERVIÇO DE CAMPO ==============
class ServicoCampoPage extends StatefulWidget {
  const ServicoCampoPage({super.key});
  @override
  State<ServicoCampoPage> createState() => _ServicoCampoPageState();
}

class _ServicoCampoPageState extends State<ServicoCampoPage> {
  static const double wMes = 65;
  static const double wSemana = 75;
  static const double wLocal = 140;
  static const double wHorario = 70;
  static const double wDirigente = 150;
  static const double hLinha = 34;
  static const List<String> _nomesMeses = [
    'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
    'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO',
  ];
  static const List<String> _grupos = ['Grupo A', 'Grupo B', 'Grupo C'];
  int _ano = 2025;
  int _mes = 9;
  late List<_LinhaServico> _linhas;

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    _linhas = _gerarLinhas(_ano, _mes);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  List<_LinhaServico> _gerarLinhas(int ano, int mes) {
    final linhas = <_LinhaServico>[];
    const nomesSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    int idxSegASex = 0;
    int idxSab = 0;
    int idxDom = 0;
    int idxGrupoDomingo = 0;
    final ultimoDia = DateTime(ano, mes + 1, 0).day;
    int ultimoDomingo = 0;
    for (int d = ultimoDia; d >= 1; d--) {
      if (DateTime(ano, mes, d).weekday == DateTime.sunday) {
        ultimoDomingo = d;
        break;
      }
    }
    for (int dia = 1; dia <= ultimoDia; dia++) {
      final data = DateTime(ano, mes, dia);
      final diaSemana = data.weekday;
      String horario = '08:30';
      if (diaSemana == DateTime.thursday) horario = '17:30';
      if (ano >= 2026 && diaSemana == DateTime.wednesday) horario = '17:30';
      String dirigente = '';
      if (diaSemana >= 1 && diaSemana <= 5) {
        final lista = DirigentesStore.validos(0);
        if (lista.isNotEmpty) {
          dirigente = lista[idxSegASex % lista.length];
          idxSegASex++;
        }
      } else if (diaSemana == 6) {
        final lista = DirigentesStore.validos(1);
        if (lista.isNotEmpty) {
          dirigente = lista[idxSab % lista.length];
          idxSab++;
        }
      } else {
        final listaSab = DirigentesStore.validos(1);
        final listaDom = DirigentesStore.validos(2);
        final combinada = [...listaSab, ...listaDom];
        if (combinada.isNotEmpty) {
          dirigente = combinada[idxDom % combinada.length];
          idxDom++;
        }
      }
      String local = '';
      if (diaSemana == DateTime.sunday) {
        if (dia == ultimoDomingo) {
          local = 'Salão do Reino';
        } else {
          local = _grupos[idxGrupoDomingo % _grupos.length];
          idxGrupoDomingo++;
        }
      }
      linhas.add(_LinhaServico(
        mes: '${dia.toString().padLeft(2, '0')}/${mes.toString().padLeft(2, '0')}',
        semana: nomesSemana[diaSemana - 1],
        horario: horario,
        dirigente: dirigente,
        local: local,
      ));
    }
    return linhas;
  }

  void _mudarMes(int delta) {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Apenas administradores podem trocar o mês.'),
        backgroundColor: C.vermelho,
      ));
      return;
    }
    setState(() {
      int novoMes = _mes + delta;
      int novoAno = _ano;
      if (novoMes < 1) {
        novoMes = 12;
        novoAno--;
      } else if (novoMes > 12) {
        novoMes = 1;
        novoAno++;
      }
      _mes = novoMes;
      _ano = novoAno;
      _linhas = _gerarLinhas(_ano, _mes);
    });
  }

  Color _corFundoLinha(_LinhaServico l) {
    if (l.semana == 'Dom') return C.vinho;
    if (l.semana == 'Sáb') return C.cinzaSabado;
    return Colors.white;
  }

  Color _corTextoLinha(_LinhaServico l) {
    if (l.semana == 'Dom') return Colors.white;
    return C.azul;
  }

  @override
  Widget build(BuildContext context) {
    final nomeMes = _nomesMeses[_mes - 1];
    final pode = AuthStore.instance.podeEditarImportante;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('SERVIÇO DE CAMPO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.borda),
              ),
              child: Row(children: [
                IconButton(
                  onPressed: () => _mudarMes(-1),
                  icon: Icon(Icons.chevron_left, color: pode ? C.azul : C.cinza),
                ),
                Expanded(
                  child: Center(
                    child: Text('$nomeMes $_ano',
                        style: const TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold, color: C.azul)),
                  ),
                ),
                IconButton(
                  onPressed: () => _mudarMes(1),
                  icon: Icon(Icons.chevron_right, color: pode ? C.azul : C.cinza),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: pode ? C.bege : const Color(0xFFFFE0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(pode ? Icons.info_outline : Icons.lock,
                    color: pode ? C.azul : C.vermelho, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pode
                        ? 'Domingos: grupos + Salão do Reino (último).'
                        : 'Somente admins editam esta tela.',
                    style: TextStyle(fontSize: 11,
                        color: pode ? C.azul : C.vermelho,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _cabecalho(),
                  ...List.generate(_linhas.length, (i) => _linha(i, _linhas[i])),
                ]),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      color: C.azulMedio,
      child: Row(children: [
        _celCabecalho('MÊS', wMes),
        _celCabecalho('SEMANA', wSemana),
        _celCabecalho('LOCAL', wLocal),
        _celCabecalho('HORÁRIO', wHorario),
        _celCabecalho('DIRIGENTE', wDirigente),
      ]),
    );
  }

  Widget _celCabecalho(String texto, double largura) {
    return Container(
      width: largura,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white24)),
      ),
      alignment: Alignment.center,
      child: Text(texto,
          style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _linha(int i, _LinhaServico l) {
    final corFundo = _corFundoLinha(l);
    final corTexto = _corTextoLinha(l);
    return Container(
      color: corFundo,
      child: Row(children: [
        _celTexto(l.mes, wMes, bold: true, corTexto: corTexto),
        _celTexto(l.semana, wSemana, corTexto: corTexto),
        _celLocal(l, wLocal, corTexto),
        _celHorario(l.horario, wHorario, corTexto: corTexto, fundoLinha: corFundo),
        _celDirigente(l.dirigente, wDirigente, corTexto: corTexto),
      ]),
    );
  }

  Widget _celTexto(String texto, double largura, {bool bold = false, Color? corTexto}) {
    return Container(
      width: largura,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      alignment: Alignment.center,
      child: Text(texto,
          style: TextStyle(fontSize: 11, color: corTexto ?? C.azul,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
    );
  }

  Widget _celHorario(String horario, double largura, {Color? corTexto, Color? fundoLinha}) {
    final isTarde = horario == '17:30';
    final corDestaque = isTarde
        ? (fundoLinha == C.vinho ? const Color(0xFFFFE0B2) : C.bege)
        : Colors.transparent;
    return Container(
      width: largura,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: corDestaque,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(horario,
            style: TextStyle(fontSize: 11, color: corTexto ?? C.azul,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _celLocal(_LinhaServico l, double largura, Color? corTexto) {
    if (l.semana == 'Dom') {
      return Container(
        width: largura,
        height: hLinha,
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: C.borda),
            bottom: BorderSide(color: C.borda),
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(l.local,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: corTexto ?? C.azul,
                fontWeight: FontWeight.bold)),
      );
    }
    return _celEditavel(largura, 'Local', (v) => l.local = v, corTexto: corTexto);
  }

  Widget _celEditavel(double largura, String hint, ValueChanged<String> onChanged,
      {Color? corTexto}) {
    final pode = AuthStore.instance.podeEditarImportante;
    return Container(
      width: largura,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      child: TextField(
        onChanged: pode ? onChanged : null,
        readOnly: !pode,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: pode ? (corTexto ?? C.azul) : C.cinza),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: pode ? hint : '—',
          hintStyle: const TextStyle(fontSize: 10, color: C.cinza),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
  }

  Widget _celDirigente(String nome, double largura, {Color? corTexto}) {
    final vazio = nome.isEmpty;
    final cor = vazio
        ? (corTexto == Colors.white ? Colors.white70 : C.cinza)
        : (corTexto ?? C.azul);
    return Container(
      width: largura,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(vazio ? '—' : nome,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: cor,
              fontWeight: vazio ? FontWeight.normal : FontWeight.w600)),
    );
  }
}

// ============== DIRIGENTE ==============
class DirigentePage extends StatefulWidget {
  const DirigentePage({super.key});
  @override
  State<DirigentePage> createState() => _DirigentePageState();
}

class _DirigentePageState extends State<DirigentePage> {
  static const int totalLinhas = 21;
  static const int totalColunas = 3;
  final List<List<TextEditingController>> _controllers = List.generate(
    totalLinhas,
    (_) => List.generate(totalColunas, (_) => TextEditingController()),
  );
  final List<String> _cabecalho = ['SEGUNDA A SEXTA', 'SÁBADO', 'DOMINGO'];

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    for (int coluna = 0; coluna < totalColunas; coluna++) {
      final lista = DirigentesStore.nomes[coluna];
      for (int i = 0; i < lista.length && i < (totalLinhas - 1); i++) {
        _controllers[i + 1][coluna].text = lista[i];
      }
    }
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    for (final linha in _controllers) {
      for (final c in linha) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  void _atualizarStore(int linha, int coluna, String valor) {
    DirigentesStore.setAt(coluna, linha - 1, valor);
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
        title: const Text('DIRIGENTE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: C.azul,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.table_chart_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('GRADE DE DIRIGENTES',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: pode ? C.bege : const Color(0xFFFFE0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(pode ? Icons.info_outline : Icons.lock,
                    color: pode ? C.azul : C.vermelho, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pode
                        ? 'Seg-Sex → seg a sex | Sábado → sáb e dom | Domingo → só dom'
                        : 'Somente admins editam esta tela.',
                    style: TextStyle(fontSize: 11,
                        color: pode ? C.azul : C.vermelho,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(totalLinhas, (linha) {
                    return Row(
                      children: List.generate(totalColunas, (coluna) {
                        if (linha == 0) {
                          return Container(
                            width: 140,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: C.azulMedio,
                              border: Border(
                                right: BorderSide(color: Colors.white24),
                                bottom: BorderSide(color: C.azul),
                              ),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(_cabecalho[coluna],
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                          );
                        }
                        return Container(
                          width: 140,
                          height: 50,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: C.borda),
                              bottom: BorderSide(color: C.borda),
                            ),
                          ),
                          child: TextField(
                            controller: _controllers[linha][coluna],
                            textAlign: TextAlign.center,
                            readOnly: !pode,
                            onChanged: pode
                                ? (v) => _atualizarStore(linha, coluna, v)
                                : null,
                            style: TextStyle(fontSize: 12,
                                color: pode ? C.azul : C.cinza,
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
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

// ============== S.13 ==============
class S13Page extends StatefulWidget {
  const S13Page({super.key});
  @override
  State<S13Page> createState() => _S13PageState();
}

class _S13PageState extends State<S13Page> {
  static const int totalLinhas = 20;
  static const int totalBlocos = 4;
  static const double hHeader1 = 30;
  static const double hHeader2 = 42;
  static const double hLinha = 74;
  static const double wTerr = 60;
  static const double wUltima = 120;
  static const double wData = 100;
  static const double wBloco = wData * 2;

  final TextEditingController _anoServico = TextEditingController();
  final List<TextEditingController> _terr =
      List.generate(totalLinhas, (_) => TextEditingController());
  final List<TextEditingController> _ultima =
      List.generate(totalLinhas, (_) => TextEditingController());
  final List<List<List<TextEditingController>>> _blocos = List.generate(
    totalLinhas,
    (_) => List.generate(
      totalBlocos,
      (_) => List.generate(3, (_) => TextEditingController()),
    ),
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
    _anoServico.dispose();
    for (final c in _terr) {
      c.dispose();
    }
    for (final c in _ultima) {
      c.dispose();
    }
    for (final linha in _blocos) {
      for (final bloco in linha) {
        for (final c in bloco) {
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
      for (int linha = 0; linha < totalLinhas; linha++) {
        final terrNum = 'T-${linha + 1}';
        if (_terr[linha].text != terrNum) _terr[linha].text = terrNum;
        final ultima = DesignacaoStore.instance.ultimaDataConclusao(terrNum);
        if (_ultima[linha].text != ultima) _ultima[linha].text = ultima;
        for (int bloco = 0; bloco < totalBlocos; bloco++) {
          final d = DesignacaoStore.instance.get(terrNum, bloco);
          if (_blocos[linha][bloco][0].text != d.nome) {
            _blocos[linha][bloco][0].text = d.nome;
          }
          if (_blocos[linha][bloco][1].text != d.dataDesignacao) {
            _blocos[linha][bloco][1].text = d.dataDesignacao;
          }
          if (_blocos[linha][bloco][2].text != d.dataConclusao) {
            _blocos[linha][bloco][2].text = d.dataConclusao;
          }
        }
      }
    });
  }

  void _limparTudo() {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Apenas administradores podem limpar a S.13.'),
        backgroundColor: C.vermelho,
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar S.13?'),
        content: const Text(
          'Isso vai apagar TODAS as designações de TODOS os territórios.\n\n'
          'Recomendado apenas após imprimir o PDF.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.vermelho),
            onPressed: () {
              DesignacaoStore.instance.limparTudo();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('S.13 limpa com sucesso!'),
                backgroundColor: C.verde,
              ));
            },
            child: const Text('Limpar tudo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          if (pode)
            IconButton(
              tooltip: 'Limpar S.13',
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: _limparTudo,
            ),
          const BadgeUsuario(),
          const BotaoSalvar(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(
              child: Text('REGISTRO DE DESIGNAÇÃO DE TERRITÓRIO',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.bold, letterSpacing: 0.3)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: C.bege,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.link, color: C.azul, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Preenchido pelo CARD DE DESIGNAÇÃO na aba TERRITÓRIOS',
                      style: TextStyle(fontSize: 10,
                          color: C.azul, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            if (pode) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.vermelho),
                ),
                child: const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: C.vermelho, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Imprima o PDF antes de tocar no ícone 🗑️ para limpar as colunas.',
                      style: TextStyle(fontSize: 11,
                          color: C.vermelho, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 10),
            Row(children: [
              const Text('Ano de Serviço: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _anoServico,
                  readOnly: !pode,
                  style: TextStyle(fontSize: 13, color: pode ? C.azul : C.cinza),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildHeader(),
                  ...List.generate(totalLinhas, (linha) => _buildDataRow(linha)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '*Ao iniciar uma nova folha, use esta coluna para registrar a data em que cada território foi concluído pela última vez.',
              style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            const Text('S-13-T 01/22', style: TextStyle(fontSize: 9)),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _cellHeader('Terr.\nn.º', wTerr, hHeader1 + hHeader2),
      _cellHeader('Última data\nconcluída*', wUltima, hHeader1 + hHeader2),
      ...List.generate(totalBlocos, (i) {
        return SizedBox(
          width: wBloco,
          child: Column(children: [
            _cellHeader('Designado para', wBloco, hHeader1),
            Row(children: [
              _cellHeader('Data da\ndesignação', wData, hHeader2),
              _cellHeader('Data da\nconclusão', wData, hHeader2),
            ]),
          ]),
        );
      }),
    ]);
  }

  Widget _cellHeader(String text, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: const BoxDecoration(
        color: C.cinzaForm,
        border: Border(
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildDataRow(int linha) {
    return Row(children: [
      _cellAuto(_terr[linha], wTerr, hLinha),
      _cellAuto(_ultima[linha], wUltima, hLinha,
          corFundo: const Color(0xFFFFF7DC), negrito: true),
      ...List.generate(totalBlocos, (bloco) => _blocoDesignado(linha, bloco)),
    ]);
  }

  Widget _blocoDesignado(int linha, int bloco) {
    return Container(
      width: wBloco,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Column(children: [
        Expanded(
          flex: 4,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: _cellAutoConteudo(_blocos[linha][bloco][0]),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.black)),
                ),
                child: _cellAutoConteudo(_blocos[linha][bloco][1]),
              ),
            ),
            Expanded(child: _cellAutoConteudo(_blocos[linha][bloco][2])),
          ]),
        ),
      ]),
    );
  }

  Widget _cellAuto(TextEditingController c, double w, double h,
      {Color? corFundo, bool negrito = false}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: corFundo,
        border: const Border(
          right: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) => Text(c.text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.black,
                fontWeight: negrito ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }

  Widget _cellAutoConteudo(TextEditingController c) {
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(c.text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11,
                color: Colors.black, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ============== EVENTOS ==============
class EventosPage extends StatefulWidget {
  const EventosPage({super.key});
  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  static const int totalGrupos = 4;
  static const int totalLinhas = 20;
  static const double wN = 45;
  static const double wNome = 130;
  static const double wDias = 100;
  static const double wPg = 60;
  static const double hLinha = 44;
  static const double hHeader = 36;

  late List<List<int>> _dias;
  late List<List<bool>> _pg;
  late List<List<TextEditingController>> _nomes;
  bool _searchAtivo = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    _dias = List.generate(totalLinhas, (_) => List.generate(totalGrupos, (_) => 0));
    _pg = List.generate(totalLinhas, (_) => List.generate(totalGrupos, (_) => false));
    _nomes = List.generate(
      totalLinhas,
      (_) => List.generate(totalGrupos, (_) => TextEditingController()),
    );
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    for (final linha in _nomes) {
      for (final c in linha) {
        c.dispose();
      }
    }
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  void _onSearch() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  bool _match(int l, int g) {
    if (_query.isEmpty) return false;
    return _nomes[l][g].text.toLowerCase().contains(_query);
  }

  int _contar() {
    if (_query.isEmpty) return 0;
    int t = 0;
    for (int l = 0; l < totalLinhas; l++) {
      for (int g = 0; g < totalGrupos; g++) {
        if (_match(l, g)) t++;
      }
    }
    return t;
  }

  String _num(int l, int g) {
    return ((g * totalLinhas) + l + 1).toString().padLeft(2, '0');
  }

  void _toggleDia(int l, int g, int bit) {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Apenas administradores podem editar esta tela.'),
        backgroundColor: C.vermelho,
        duration: Duration(seconds: 1),
      ));
      return;
    }
    setState(() => _dias[l][g] ^= bit);
  }

  void _togglePg(int l, int g) {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Apenas administradores podem editar esta tela.'),
        backgroundColor: C.vermelho,
        duration: Duration(seconds: 1),
      ));
      return;
    }
    setState(() => _pg[l][g] = !_pg[l][g]);
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
        title: _searchAtivo
            ? TextField(
                controller: _searchController,
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
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_searchAtivo ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_searchAtivo) {
                  _searchAtivo = false;
                  _searchController.clear();
                  _query = '';
                } else {
                  _searchAtivo = true;
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                child: Column(children: [
                  _cabecalho(),
                  ...List.generate(totalLinhas, (l) => _linha(l, pode)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _aviso(bool pode) {
    if (_query.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: C.amareloClaro,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.amarelo),
        ),
        child: Row(children: [
          const Icon(Icons.search, color: C.azul, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _contar() == 0
                  ? 'Nenhum resultado para "$_query"'
                  : '${_contar()} resultado(s) para "$_query"',
              style: const TextStyle(fontSize: 12,
                  color: C.azul, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: pode ? C.bege : const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(pode ? Icons.info_outline : Icons.lock,
            color: pode ? C.azul : C.vermelho, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            pode
                ? 'Marque os dias (SEX/SÁB/DOM) e o pagamento (PG). Use a lupa.'
                : 'Modo leitura: apenas admins editam.',
            style: TextStyle(fontSize: 11,
                color: pode ? C.azul : C.vermelho,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }

  Widget _cabecalho() {
    return Container(
      color: C.azulMedio,
      child: Row(
        children: List.generate(totalGrupos, (g) {
          return Row(children: [
            _celCab('Nº', wN),
            _celCab('NOME', wNome),
            _celCab('DIAS', wDias),
            _celCab('PG', wPg),
          ]);
        }),
      ),
    );
  }

  Widget _celCab(String t, double w) {
    return Container(
      width: w,
      height: hHeader,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white24)),
      ),
      alignment: Alignment.center,
      child: Text(t,
          style: const TextStyle(color: Colors.white,
              fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.3)),
    );
  }

  Widget _linha(int l, bool pode) {
    return Container(
      color: l.isEven ? Colors.white : const Color(0xFFF9FAFB),
      child: Row(
        children: List.generate(totalGrupos, (g) {
          return Row(children: [
            _celNum(l, g),
            _celNome(l, g, pode),
            _celDias(l, g),
            _celPg(l, g),
          ]);
        }),
      ),
    );
  }

  Widget _celNum(int l, int g) {
    return Container(
      width: wN,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      alignment: Alignment.center,
      child: Text(_num(l, g),
          style: const TextStyle(fontSize: 12, color: C.azul,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _celNome(int l, int g, bool pode) {
    final dest = _match(l, g);
    return Container(
      width: wNome,
      height: hLinha,
      decoration: BoxDecoration(
        color: dest ? C.amareloClaro : Colors.transparent,
        border: Border(
          right: const BorderSide(color: C.borda),
          bottom: const BorderSide(color: C.borda),
          top: dest ? const BorderSide(color: C.amarelo, width: 2) : BorderSide.none,
          left: dest ? const BorderSide(color: C.amarelo, width: 2) : BorderSide.none,
        ),
      ),
      child: TextField(
        controller: _nomes[l][g],
        textAlign: TextAlign.center,
        readOnly: !pode,
        onChanged: pode ? (_) => setState(() {}) : null,
        style: TextStyle(fontSize: 11,
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

  Widget _celDias(int l, int g) {
    return Container(
      width: wDias,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _botaoDia(l, g, 1, 'SEX'),
        const SizedBox(width: 3),
        _botaoDia(l, g, 2, 'SÁB'),
        const SizedBox(width: 3),
        _botaoDia(l, g, 4, 'DOM'),
      ]),
    );
  }

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
            style: TextStyle(fontSize: 9,
                color: ativo ? Colors.white : C.azul,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _celPg(int l, int g) {
    final pago = _pg[l][g];
    return Container(
      width: wPg,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
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
          child: Text(pago ? 'PAGO' : 'N/PG',
              style: TextStyle(fontSize: 9,
                  color: pago ? Colors.white : Colors.red.shade700,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ============== ADMINISTRADOR ==============
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('ADMINISTRADOR',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AuthStore.instance.logado ? _painel() : _login(),
        ),
      ),
    );
  }

  Widget _login() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          const Icon(Icons.lock_outline, color: C.azul, size: 60),
          const SizedBox(height: 12),
          const Text('Acesso do Administrador',
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold, color: C.azul)),
          const SizedBox(height: 4),
          const Text('Somente administradores podem editar partes importantes do app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: C.cinza)),
          const SizedBox(height: 20),
          const _LoginForm(),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.bege,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Permissões',
              style: TextStyle(fontWeight: FontWeight.bold,
                  color: C.azul, fontSize: 14)),
          SizedBox(height: 8),
          _ItemPermissao(icon: Icons.verified_user,
              texto: 'Admin Principal: cadastra A, B, C e edita tudo'),
          SizedBox(height: 6),
          _ItemPermissao(icon: Icons.admin_panel_settings,
              texto: 'Admins A, B, C: editam tudo'),
          SizedBox(height: 6),
          _ItemPermissao(icon: Icons.person_outline,
              texto: 'Publicador: só edita a aba Territórios'),
        ]),
      ),
    ]);
  }

  Widget _painel() {
    final u = AuthStore.instance;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.verde,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          const Icon(Icons.verified_user, color: Colors.white, size: 60),
          const SizedBox(height: 10),
          Text('Bem-vindo, ${u.nomeUsuario}',
              style: const TextStyle(color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            u.isPrincipal
                ? 'Você pode cadastrar admins A, B e C'
                : 'Você pode editar as partes importantes do app',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
      const SizedBox(height: 16),
      if (u.isPrincipal) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Row(children: [
              Icon(Icons.group_add, color: C.azul, size: 22),
              SizedBox(width: 8),
              Text('Cadastro de Admins (A, B, C)',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: C.azul, fontSize: 14)),
            ]),
            const SizedBox(height: 12),
            for (final letra in ['A', 'B', 'C']) _LinhaAdmin(letra: letra),
          ]),
        ),
        const SizedBox(height: 16),
      ],
      SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {
            AuthStore.instance.logout();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Sessão encerrada'),
              duration: Duration(seconds: 1),
            ));
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sair',
              style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: C.vermelho,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _LinhaAdmin extends StatefulWidget {
  final String letra;
  const _LinhaAdmin({required this.letra});
  @override
  State<_LinhaAdmin> createState() => _LinhaAdminState();
}

class _LinhaAdminState extends State<_LinhaAdmin> {
  final TextEditingController _ctrl = TextEditingController();
  bool _oculto = true;

  @override
  void initState() {
    super.initState();
    _ctrl.text = AuthStore.instance.admins[widget.letra] ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: C.azul,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(widget.letra,
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _ctrl,
            obscureText: _oculto,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, color: C.azul),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Senha do admin ${widget.letra}',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(
                  _oculto ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: C.cinza,
                ),
                onPressed: () => setState(() => _oculto = !_oculto),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.check_circle, color: C.verde),
          onPressed: () {
            final nova = _ctrl.text.trim();
            if (nova.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('A senha não pode estar vazia'),
                backgroundColor: C.vermelho,
                duration: Duration(seconds: 1),
              ));
              return;
            }
            final ok = AuthStore.instance.alterarSenhaAdmin(widget.letra, nova);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok
                  ? 'Senha do admin ${widget.letra} atualizada'
                  : 'Não foi possível atualizar'),
              backgroundColor: ok ? C.verde : C.vermelho,
              duration: const Duration(seconds: 1),
            ));
          },
        ),
      ]),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  String _tipo = 'PRINCIPAL';
  final TextEditingController _senha = TextEditingController();
  bool _oculto = true;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  void _entrar() {
    final s = _senha.text.trim();
    if (s.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Digite a senha'),
        backgroundColor: C.vermelho,
        duration: Duration(seconds: 1),
      ));
      return;
    }
    final ok = AuthStore.instance.login(_tipo, s);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Senha incorreta'),
        backgroundColor: C.vermelho,
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Entrar como:',
          style: TextStyle(fontSize: 12, color: C.cinza)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.borda),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _tipo,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'PRINCIPAL', child: Text('Admin Principal')),
              DropdownMenuItem(value: 'A', child: Text('Admin A')),
              DropdownMenuItem(value: 'B', child: Text('Admin B')),
              DropdownMenuItem(value: 'C', child: Text('Admin C')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _tipo = v);
            },
          ),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _senha,
        obscureText: _oculto,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14, color: C.azul),
        decoration: InputDecoration(
          isDense: true,
          labelText: 'Senha',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _oculto ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: C.cinza,
            ),
            onPressed: () => setState(() => _oculto = !_oculto),
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _entrar,
          icon: const Icon(Icons.login),
          label: const Text('Entrar',
              style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: C.azul,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _ItemPermissao extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _ItemPermissao({required this.icon, required this.texto});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: C.azul, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(texto,
            style: const TextStyle(fontSize: 12, color: C.azul)),
      ),
    ]);
  }
}

// ============== MODELO AUXILIAR ==============
class _LinhaServico {
  final String mes;
  final String semana;
  final String horario;
  String local;
  String dirigente;
  _LinhaServico({
    required this.mes,
    required this.semana,
    required this.horario,
    this.local = '',
    this.dirigente = '',
  });
}
