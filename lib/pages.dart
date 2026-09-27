import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'cloud.dart';
import 'tema.dart';
import 'stores.dart';
import 'widgets.dart';
import 'servo_territorio.dart';

// ============== HOME ==============
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _abaAtual = 0;
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onChanged);
    AuthStore.instance.addListener(_onChanged);
  }
  @override
  void dispose() {
    AppState.instance.removeListener(_onChanged);
    AuthStore.instance.removeListener(_onChanged);
    super.dispose();
  }
  void _onChanged() {
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Início',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _header(),
              const SizedBox(height: 12),
              _infoSalvamento(),
              const SizedBox(height: 12),
              _infoPermissao(),
              const SizedBox(height: 16),
              _grid(),
              const SizedBox(height: 20),
              _cardMapa(),
              const SizedBox(height: 16),
              _cardNotas(),
            ]),
          )),
          _bottomNav(),
        ]),
      ),
    );
  }
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(color: C.azul, borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Text('Território de Congregação',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
  Widget _infoSalvamento() {
    final s = AppState.instance.lastSaved != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: s ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: s ? const Color(0xFFA8D5A8) : C.amarelo),
      ),
      child: Row(children: [
        Icon(s ? Icons.cloud_done : Icons.cloud_off, color: s ? C.verde : C.amarelo, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s ? 'Último salvamento' : 'Nenhum salvamento ainda',
              style: TextStyle(fontSize: 11, color: s ? C.verde : C.amarelo, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(AppState.instance.lastSavedText,
              style: const TextStyle(fontSize: 13, color: C.azul, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
  Widget _infoPermissao() {
    final p = AuthStore.instance.podeEditarImportante;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p ? const Color(0xFFA8D5A8) : C.amarelo),
      ),
      child: Row(children: [
        Icon(p ? Icons.lock_open : Icons.lock_outline, color: p ? C.verde : C.amarelo, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p ? 'Modo administrador' : 'Modo publicador',
              style: TextStyle(fontSize: 12, color: p ? C.verde : C.amarelo, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(p ? 'Pode editar todas as partes do app' : 'Só edita a aba Territórios',
              style: const TextStyle(fontSize: 11, color: C.azul)),
        ])),
      ]),
    );
  }
  Widget _grid() {
    final items = [
      {'icon': Icons.map_outlined, 'label': 'Territórios', 'acao': 'territorios'},
      {'icon': Icons.menu_book_outlined, 'label': 'Serviço de Campo', 'acao': 'servico'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Eventos', 'acao': 'eventos'},
      {'icon': Icons.person_pin_circle_outlined, 'label': 'Dirigentes', 'acao': 'dirigente'},
      {'icon': Icons.assignment_outlined, 'label': 'S.13', 'acao': 's13'},
      {'icon': Icons.admin_panel_settings_outlined, 'label': 'Administrador', 'acao': 'admin'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, i) => _cardMenu(
        icon: items[i]['icon'] as IconData,
        label: items[i]['label'] as String,
        acao: items[i]['acao'] as String,
      ),
    );
  }
  Widget _cardMenu({required IconData icon, required String label, required String acao}) {
    return Container(
      decoration: BoxDecoration(
        color: C.bege,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.azul.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: C.azul.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (acao == 'eventos' ||
                acao == 's13' ||
                acao == 'dirigente') {
              if (!AuthStore.instance.podeEditarImportante) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Apenas administradores podem abrir esta aba.'),
                  backgroundColor: C.vermelho,
                  duration: Duration(seconds: 2),
                ));
                return;
              }
            }

            if (acao == 'territorios') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TerritoriosPage()));
            } else if (acao == 'servico') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicoCampoPage()));
            } else if (acao == 'dirigente') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DirigentePage()));
            } else if (acao == 's13') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const S13Page()));
            } else if (acao == 'eventos') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EventosPage()));
            } else if (acao == 'admin') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 30, color: C.azul),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: C.azul, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _cardMapa() {
    return Row(
      children: [
        Expanded(
          child: _botaoHome(
            icon: Icons.person_pin_circle,
            label: 'SERVO DE\nTERRITÓRIO',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServoTerritorioPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _botaoHome(
            icon: Icons.event,
            label: 'SERVO DE\nEVENTOS',
            onTap: () {
              // TODO: navegar para Servo de Eventos
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _botaoHome(
            icon: Icons.menu_book,
            label: 'TUTORIAL',
            onTap: () {
              // TODO: navegar para Tutorial
            },
          ),
        ),
      ],
    );
  }
  Widget _botaoHome({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: C.bege,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.azul.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: C.azul.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: C.azul),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: C.azul,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _cardNotas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Notas recentes do serviço',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: C.azul)),
        SizedBox(height: 12),
        Text('Nenhuma nota recente...',
            style: TextStyle(color: C.cinza, fontStyle: FontStyle.italic, fontSize: 13)),
      ]),
    );
  }
  Widget _bottomNav() {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.person_outline, 'label': 'Meu Perfil'},
      {'icon': Icons.mail_outline, 'label': 'Mensagens'},
      {'icon': Icons.settings_outlined, 'label': 'Configurações'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final ativo = i == _abaAtual;
          return InkWell(
            onTap: () => setState(() => _abaAtual = i),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i]['icon'] as IconData,
                    color: ativo ? C.azul : C.cinza, size: 24),
                const SizedBox(height: 4),
                Text(items[i]['label'] as String,
                    style: TextStyle(fontSize: 10, color: ativo ? C.azul : C.cinza,
                        fontWeight: ativo ? FontWeight.bold : FontWeight.normal)),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ============== TERRITÓRIOS ==============
class TerritoriosPage extends StatefulWidget {
  const TerritoriosPage({super.key});
  @override
  State<TerritoriosPage> createState() => _TerritoriosPageState();
}

class _TerritoriosPageState extends State<TerritoriosPage> {
  @override
  void initState() {
    super.initState();
    TerritoriosStore.instance.addListener(_onChanged);
    AuthStore.instance.addListener(_onChanged);
  }
  @override
  void dispose() {
    TerritoriosStore.instance.removeListener(_onChanged);
    AuthStore.instance.removeListener(_onChanged);
    super.dispose();
  }
  void _onChanged() {
    if (mounted) setState(() {});
  }
  void _editarNome(int index) {
    final t = TerritoriosStore.instance.lista[index];
    final ctrl = TextEditingController(text: t.nome);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Renomear ${t.numero}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome do território',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.azul),
            onPressed: () {
              final novo = ctrl.text.trim();
              if (novo.isNotEmpty) TerritoriosStore.instance.renomear(index, novo);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final lista = TerritoriosStore.instance.lista;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('TERRITÓRIOS DA CONGREGAÇÃO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final t = lista[index];
            final liberado = t.liberado;

            return Material(
              color: liberado ? Colors.white : const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(14),
              elevation: liberado ? 2 : 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (!liberado) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Território bloqueado. Peça ao servo de território para liberar.',
                        ),
                        backgroundColor: C.vermelho,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalheTerritorioPage(
                        numero: t.numero,
                        nome: t.nome,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(children: [
                    Icon(
                      liberado ? Icons.map : Icons.lock_outline,
                      color: liberado ? C.azul : C.cinza,
                      size: 38,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.numero} ${t.nome}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: liberado ? C.azul : C.cinza,
                            ),
                          ),
                          if (!liberado)
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                'Bloqueado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: C.cinza,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (liberado) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: C.azul, size: 22),
                        onPressed: () => _editarNome(index),
                      ),
                      const Icon(Icons.play_arrow, color: C.amarelo, size: 30),
                    ] else
                      const Icon(Icons.lock, color: C.cinza, size: 22),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// ============== DETALHE TERRITÓRIO ==============
class DetalheTerritorioPage extends StatefulWidget {
  final String numero;
  final String nome;
  const DetalheTerritorioPage({super.key, required this.numero, required this.nome});
  @override
  State<DetalheTerritorioPage> createState() => _DetalheTerritorioPageState();
}

class _DetalheTerritorioPageState extends State<DetalheTerritorioPage> {
  String? _fotoMapa;
  late List<List<int>> _quadrasEstados;
  final List<String> _cabecalhoDirigente = [
    'DIRIGENTE', 'PUBLI', 'DATA',
    'DIRIGENTE', 'PUBLI', 'DATA',
    'DIRIGENTE', 'PUBLI', 'DATA',
    'DATA INICIAL', 'DATA FINAL',
  ];
  final List<List<TextEditingController>> _dirigenteControllers =
      List.generate(11, (_) => List.generate(11, (_) => TextEditingController()));

  final _ctrlNome = TextEditingController();
  final _ctrlDataInicial = TextEditingController();
  final _ctrlDataConclusao = TextEditingController();
  final _ctrlObs = TextEditingController();

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    DesignacaoStore.instance.addListener(_onDesig);
    ObsStore.instance.addListener(_onDesig);
    _ctrlObs.text = ObsStore.instance.get(widget.numero);
    _fotoMapa = MapasStore.get(widget.numero);
    _quadrasEstados = QuadrasStore.get(widget.numero);
    for (int l = 0; l < 11; l++) {
      for (int c = 0; c < 11; c++) {
        _dirigenteControllers[l][c].text =
            DirigenteTerritorioStore.valor(widget.numero, l, c);
      }
    }
  }
  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    DesignacaoStore.instance.removeListener(_onDesig);
    ObsStore.instance.removeListener(_onDesig);
    for (final l in _dirigenteControllers) {
      for (final c in l) { c.dispose(); }
    }
    _ctrlNome.dispose();
    _ctrlDataInicial.dispose();
    _ctrlDataConclusao.dispose();
    _ctrlObs.dispose();
    super.dispose();
  }
  void _onAuth() { if (mounted) setState(() {}); }
  void _onDesig() { if (mounted) setState(() {}); }

  int _proximoBlocoLivre() {
    for (int i = 0; i < 4; i++) {
      final d = DesignacaoStore.instance.get(widget.numero, i);
      if (d.nome.isEmpty && d.dataDesignacao.isEmpty) return i;
      if (d.dataConclusao.isEmpty && d.nome.isNotEmpty) return i;
    }
    return -1;
  }
  Designacao? _designacaoAtiva() {
    for (int i = 0; i < 4; i++) {
      final d = DesignacaoStore.instance.get(widget.numero, i);
      if (d.nome.isNotEmpty && d.dataConclusao.isEmpty) return d;
    }
    return null;
  }
  int _blocoAtivoIndex() {
    for (int i = 0; i < 4; i++) {
      final d = DesignacaoStore.instance.get(widget.numero, i);
      if (d.nome.isNotEmpty && d.dataConclusao.isEmpty) return i;
    }
    return -1;
  }
  void _iniciarDesignacao() {
    final nome = _ctrlNome.text.trim();
    final data = _ctrlDataInicial.text.trim();
    if (nome.isEmpty || data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Preencha nome e data'),
        backgroundColor: C.vermelho,
      ));
      return;
    }
    final bloco = _proximoBlocoLivre();
    if (bloco == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('As 4 colunas já estão preenchidas. Limpe a S.13.'),
        backgroundColor: C.vermelho,
      ));
      return;
    }
    DesignacaoStore.instance.set(widget.numero, bloco,
        Designacao(nome: nome, dataDesignacao: data, dataConclusao: ''));
    _ctrlNome.clear();
    _ctrlDataInicial.clear();
    _ctrlDataConclusao.clear();
  }
  void _concluirDesignacao() {
    final data = _ctrlDataConclusao.text.trim();
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Preencha a data de conclusão'),
        backgroundColor: C.vermelho,
      ));
      return;
    }
    final bloco = _blocoAtivoIndex();
    if (bloco == -1) return;
    final d = DesignacaoStore.instance.get(widget.numero, bloco);
    DesignacaoStore.instance.set(widget.numero, bloco,
        Designacao(nome: d.nome, dataDesignacao: d.dataDesignacao, dataConclusao: data));
    _ctrlDataConclusao.clear();
  }

  Widget _buildCardDesignacao() {
    final ativa = _designacaoAtiva();
    if (ativa != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7DC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.amarelo, width: 2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Row(children: [
            Icon(Icons.person_pin_circle, color: C.amarelo, size: 20),
            SizedBox(width: 6),
            Text('Designação em andamento',
                style: TextStyle(fontWeight: FontWeight.bold, color: C.azul, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text('Dirigente: ${ativa.nome}', style: const TextStyle(fontSize: 13, color: C.azul)),
          Text('Data designação: ${ativa.dataDesignacao}',
              style: const TextStyle(fontSize: 13, color: C.azul)),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrlDataConclusao,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'Data de conclusão',
              hintText: 'dd/mm/aaaa',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: C.verde, foregroundColor: Colors.white),
            onPressed: _concluirDesignacao,
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Concluir designação'),
          ),
        ]),
      );
    }
    final proximo = _proximoBlocoLivre();
    if (proximo == -1) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4EA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.verde, width: 2),
        ),
        child: const Row(children: [
          Icon(Icons.check_circle, color: C.verde, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text('As 4 colunas estão preenchidas. Limpe a S.13 para novas.',
              style: TextStyle(fontSize: 12, color: C.verde, fontWeight: FontWeight.w600))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.borda),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.add_circle_outline, color: C.azul, size: 20),
          const SizedBox(width: 6),
          Text('Nova designação (coluna ${proximo + 1} de 4)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: C.azul, fontSize: 13)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrlNome,
          decoration: InputDecoration(
            labelText: 'Nome do dirigente',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrlDataInicial,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Data de designação',
            hintText: 'dd/mm/aaaa',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: C.azul, foregroundColor: Colors.white),
          onPressed: _iniciarDesignacao,
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Iniciar designação'),
        ),
      ]),
    );
  }

  void _alternarCelula(int linha, int coluna) {
    setState(() {
      _quadrasEstados[linha][coluna] = (_quadrasEstados[linha][coluna] + 1) % 3;
      QuadrasStore.set(widget.numero, _quadrasEstados);
    });
  }
  Color _corCelula(int estado) {
    switch (estado) {
      case 1: return const Color(0xFFFFEB99);
      case 2: return const Color(0xFFA8D5A8);
      default: return Colors.white;
    }
  }

  Future<void> _abrirOpcoesFoto() async {
    if (!AuthStore.instance.podeEditarImportante) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Apenas administradores podem alterar a foto do mapa.'),
        backgroundColor: C.vermelho,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: C.cinza, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Foto do mapa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: C.azul)),
          const SizedBox(height: 20),
          _opcaoFoto(Icons.photo_library_outlined, 'Escolher da galeria', () async {
            Navigator.pop(ctx);
            await _escolherImagem(ImageSource.gallery);
          }),
          const SizedBox(height: 8),
          _opcaoFoto(Icons.camera_alt_outlined, 'Tirar foto', () async {
            Navigator.pop(ctx);
            await _escolherImagem(ImageSource.camera);
          }),
          if (_fotoMapa != null && _fotoMapa!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _opcaoFoto(Icons.delete_outline, 'Remover foto', () {
              Navigator.pop(ctx);
              setState(() => _fotoMapa = null);
              MapasStore.set(widget.numero, null);
            }, cor: Colors.red),
          ],
        ]),
      )),
    );
  }

  Future<void> _escolherImagem(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 40,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      if (!mounted) return;
      setState(() => _fotoMapa = base64Str);
      MapasStore.set(widget.numero, base64Str);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao escolher imagem: $e'),
        backgroundColor: C.vermelho,
      ));
    }
  }

  Widget _opcaoFoto(IconData icon, String label, VoidCallback onTap, {Color? cor}) {
    return Material(
      color: C.bege,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, color: cor ?? C.azul, size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: cor ?? C.azul)),
          ]),
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
        title: Text(widget.numero, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _cardNome(),
            const SizedBox(height: 16),
            _areaFoto(),
            const SizedBox(height: 12),
            _botaoFoto(),
            const SizedBox(height: 24),
            _tituloGrade('DESIGNAÇÃO (alimenta a S.13)'),
            const SizedBox(height: 8),
            _buildCardDesignacao(),
            const SizedBox(height: 24),
            _tituloGrade('DIRIGENTE'),
            const SizedBox(height: 8),
            _infoIntegracao(),
            const SizedBox(height: 8),
            _gradeDirigente(),
            const SizedBox(height: 24),
            _tituloGrade('QUADRAS TRABALHADAS'),
            const SizedBox(height: 8),
            _legenda(),
            const SizedBox(height: 8),
            _gradeQuadras(),
            const SizedBox(height: 24),
            _tituloGrade('OBSERVAÇÕES'),
            const SizedBox(height: 8),
            _cardObservacoes(),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
  Widget _cardNome() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.map, color: C.azul, size: 36),
        const SizedBox(width: 12),
        Expanded(child: Text('${widget.numero} ${widget.nome}',
            style: const TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold, color: C.azul))),
      ]),
    );
  }
  Widget _areaFoto() {
    return Container(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: (_fotoMapa != null && _fotoMapa!.isNotEmpty)
          ? Image.memory(
              base64Decode(_fotoMapa!),
              fit: BoxFit.fitWidth,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            )
          : const SizedBox(
              height: 240,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 60, color: C.cinza),
                  SizedBox(height: 10),
                  Text('Nenhuma foto do mapa',
                      style: TextStyle(fontSize: 13, color: C.cinza)),
                ],
              ),
            ),
    );
  }
  Widget _botaoFoto() {
    final pode = AuthStore.instance.podeEditarImportante;
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _abrirOpcoesFoto,
        icon: Icon(
          !pode
              ? Icons.lock_outline
              : (_fotoMapa != null ? Icons.edit : Icons.add_a_photo_outlined),
          size: 18,
        ),
        label: Text(
          !pode
              ? 'Somente admin altera foto'
              : (_fotoMapa != null ? 'Alterar foto do mapa' : 'Adicionar foto do mapa'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: pode ? C.azul : C.cinza,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
  Widget _tituloGrade(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: C.azul, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.table_chart_outlined, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(t, style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
      ]),
    );
  }
  Widget _infoIntegracao() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: C.bege, borderRadius: BorderRadius.circular(8)),
      child: const Row(children: [
        Icon(Icons.edit_note, color: C.azul, size: 16),
        SizedBox(width: 8),
        Expanded(child: Text(
          'Grade de anotações livres. O card acima é o que alimenta a S.13.',
          style: TextStyle(fontSize: 11, color: C.azul, fontWeight: FontWeight.w600),
        )),
      ]),
    );
  }
  Widget _legenda() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.borda),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _itemLegenda(Colors.white, 'Vazio'),
        _itemLegenda(const Color(0xFFFFEB99), '1 toque'),
        _itemLegenda(const Color(0xFFA8D5A8), '2 toques'),
      ]),
    );
  }
  Widget _itemLegenda(Color cor, String texto) {
    return Row(children: [
      Container(width: 18, height: 18,
          decoration: BoxDecoration(color: cor,
              border: Border.all(color: C.borda),
              borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 6),
      Text(texto, style: const TextStyle(fontSize: 11,
          color: C.azul, fontWeight: FontWeight.w600)),
    ]);
  }
  Widget _cardObservacoes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.borda),
      ),
      child: TextField(
        controller: _ctrlObs,
        maxLines: 5,
        minLines: 3,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontSize: 13, color: C.azul),
        onChanged: (v) => ObsStore.instance.set(widget.numero, v),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Digite aqui observações sobre este território...',
          hintStyle: TextStyle(fontSize: 12, color: C.cinza),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
  Widget _gradeDirigente() {
    const double w = 100;
    const double h = 44;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(11, (linha) {
            return Row(children: List.generate(11, (coluna) {
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
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 11)),
                );
              }
              return Container(
                width: w,
                height: h,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: C.borda),
                    bottom: BorderSide(color: C.borda),
                  ),
                ),
                child: TextField(
                  controller: _dirigenteControllers[linha][coluna],
                  textAlign: TextAlign.center,
                  onChanged: (v) => DirigenteTerritorioStore.set(
                      widget.numero, linha, coluna, v),
                  style: const TextStyle(fontSize: 12, color: C.azul),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  ),
                ),
              );
            }));
          }),
        ),
      ),
    );
  }
  Widget _gradeQuadras() {
    const double w = 60;
    const double h = 44;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(11, (linha) {
            return Row(children: List.generate(14, (coluna) {
              if (linha == 0) {
                final numero = (coluna + 1).toString().padLeft(2, '0');
                return Container(
                  width: w,
                  height: h,
                  decoration: const BoxDecoration(
                    color: C.azulMedio,
                    border: Border(right: BorderSide(color: Colors.white24)),
                  ),
                  alignment: Alignment.center,
                  child: Text(numero,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 13)),
                );
              }
              final estado = _quadrasEstados[linha - 1][coluna];
              return GestureDetector(
                onTap: () => _alternarCelula(linha - 1, coluna),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: _corCelula(estado),
                    border: const Border(
                      right: BorderSide(color: C.borda),
                      bottom: BorderSide(color: C.borda),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: estado == 0
                      ? null
                      : Icon(
                          estado == 1 ? Icons.edit : Icons.check,
                          size: 18,
                          color: estado == 1 ? C.amarelo : const Color(0xFF2F855A),
                        ),
                ),
              );
            }));
          }),
        ),
      ),
    );
  }
}

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
    AuthStore.instance.addListener(_onChanged);
    ServicoCampoStore.instance.addListener(_onChanged);
    _linhas = _gerarLinhas(_ano, _mes);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onChanged);
    ServicoCampoStore.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
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
      final dataKey = '$ano-${mes.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
      linhas.add(_LinhaServico(
        dataKey: dataKey,
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
    final pode = AuthStore.instance.podeEditarImportante;
    final nomeMes = _nomesMeses[_mes - 1];
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
    final pode = AuthStore.instance.podeEditarImportante;
    final saved = ServicoCampoStore.instance.locais[l.dataKey] ?? '';
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
        controller: TextEditingController(text: saved)
          ..selection = TextSelection.collapsed(offset: saved.length),
        onChanged: pode
            ? (v) => ServicoCampoStore.instance.setLocal(l.dataKey, v)
            : null,
        readOnly: !pode,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: pode ? (corTexto ?? C.azul) : C.cinza),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: pode ? 'Local' : '—',
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
