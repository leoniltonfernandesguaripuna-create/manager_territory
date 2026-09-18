import 'package:flutter/material.dart';
import 'cores.dart';
import 'stores.dart';
import 'widgets.dart';

// ========== HOME ==========
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _aba = 0;
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_on);
    AuthStore.instance.addListener(_on);
  }
  @override
  void dispose() {
    AppState.instance.removeListener(_on);
    AuthStore.instance.removeListener(_on);
    super.dispose();
  }
  void _on() { if (mounted) setState(() {}); }
  void _abrir(Widget w) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => w));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        title: const Text('Início',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                decoration: BoxDecoration(color: C.azul, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('Territory Manager',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
              ),
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
          Text(s ? 'Último salvamento' : 'Nenhum salvamento',
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
          Text(p ? 'Permissão de administrador' : 'Modo visitante',
              style: TextStyle(fontSize: 12, color: p ? C.verde : C.amarelo, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(p ? 'Pode editar tudo' : 'Só DIRIGENTE e QUADRAS',
              style: const TextStyle(fontSize: 11, color: C.azul)),
        ])),
      ]),
    );
  }

  Widget _grid() {
    final items = [
      {'i': Icons.map_outlined, 'l': 'Territórios', 'a': 'territorios'},
      {'i': Icons.menu_book_outlined, 'l': 'Serviço de Campo', 'a': 'servico'},
      {'i': Icons.calendar_today_outlined, 'l': 'Eventos', 'a': 'eventos'},
      {'i': Icons.person_pin_circle_outlined, 'l': 'Dirigente', 'a': 'dirigente'},
      {'i': Icons.assignment_outlined, 'l': 'S.13', 'a': 's13'},
      {'i': Icons.admin_panel_settings_outlined, 'l': 'Administrador', 'a': 'admin'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.05),
      itemBuilder: (c, i) {
        return Material(
          color: C.bege,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final a = items[i]['a'] as String;
              if (a == 'territorios') _abrir(const TerritoriosPage());
              else if (a == 'servico') _abrir(const ServicoCampoPage());
              else if (a == 'eventos') _abrir(const EventosPage());
              else if (a == 'dirigente') _abrir(const DirigentePage());
              else if (a == 's13') _abrir(const S13Page());
              else if (a == 'admin') _abrir(const AdminPage());
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(items[i]['i'] as IconData, size: 30, color: C.azul),
                const SizedBox(height: 8),
                Text(items[i]['l'] as String, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: C.azul, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _cardMapa() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Visão Geral', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: C.azul)),
          Icon(Icons.chevron_right, color: C.cinza),
        ]),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(color: C.bege, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Icon(Icons.map_outlined, size: 60, color: C.cinza)),
        ),
      ]),
    );
  }

  Widget _cardNotas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Notas recentes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: C.azul)),
        const SizedBox(height: 12),
        const Text('Nenhuma nota...', style: TextStyle(color: C.cinza, fontStyle: FontStyle.italic, fontSize: 13)),
      ]),
    );
  }

  Widget _bottomNav() {
    final items = [
      {'i': Icons.home, 'l': 'Home'},
      {'i': Icons.person_outline, 'l': 'Perfil'},
      {'i': Icons.mail_outline, 'l': 'Mensagens'},
      {'i': Icons.settings_outlined, 'l': 'Config'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final a = i == _aba;
          return InkWell(
            onTap: () => setState(() => _aba = i),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i]['i'] as IconData, color: a ? C.azul : C.cinza, size: 24),
                const SizedBox(height: 4),
                Text(items[i]['l'] as String,
                    style: TextStyle(fontSize: 10, color: a ? C.azul : C.cinza,
                        fontWeight: a ? FontWeight.bold : FontWeight.normal)),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ========== TERRITÓRIOS ==========
class TerritoriosPage extends StatelessWidget {
  const TerritoriosPage({super.key});
  static const lista = [
    {'n': 'T-1', 'nm': 'St Terezinha 1'},
    {'n': 'T-2', 'nm': 'St Terezinha 2'},
    {'n': 'T-3', 'nm': 'Fantinato 1'},
    {'n': 'T-4', 'nm': 'Fantinato 2'},
    {'n': 'T-5', 'nm': 'Fantinato 3'},
    {'n': 'T-6', 'nm': 'Jd Vitória'},
    {'n': 'T-7', 'nm': 'Chaparral 1'},
    {'n': 'T-8', 'nm': 'Chaparral 2'},
    {'n': 'T-9', 'nm': 'Centro'},
    {'n': 'T-10', 'nm': 'Vila Nova'},
    {'n': 'T-11', 'nm': 'Boa Esperança'},
    {'n': 'T-12', 'nm': 'Santa Rita'},
    {'n': 'T-13', 'nm': 'São José'},
    {'n': 'T-14', 'nm': 'Ipê Amarelo'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: const Text('TERRITÓRIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (c, i) {
            final t = lista[i];
            return Material(
              color: Colors.white, borderRadius: BorderRadius.circular(14), elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => DetalheTerritorioPage(numero: t['n']!, nome: t['nm']!))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(children: [
                    const Icon(Icons.map, color: C.azul, size: 38),
                    const SizedBox(width: 16),
                    Expanded(child: Text('${t['n']} ${t['nm']}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: C.azul))),
                    const Icon(Icons.play_arrow, color: C.amarelo, size: 30),
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

// ========== DETALHE TERRITÓRIO ==========
class DetalheTerritorioPage extends StatefulWidget {
  final String numero;
  final String nome;
  const DetalheTerritorioPage({super.key, required this.numero, required this.nome});
  @override
  State<DetalheTerritorioPage> createState() => _DetalheTerritorioPageState();
}

class _DetalheTerritorioPageState extends State<DetalheTerritorioPage> {
  final List<List<int>> _q = List.generate(10, (_) => List.generate(14, (_) => 0));
  void _toggle(int l, int c) {
    setState(() => _q[l][c] = (_q[l][c] + 1) % 3);
  }
  Color _cor(int e) {
    if (e == 1) return const Color(0xFFFFEB99);
    if (e == 2) return const Color(0xFFA8D5A8);
    return Colors.white;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: Text(widget.numero, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.map, color: C.azul, size: 36),
                const SizedBox(width: 12),
                Expanded(child: Text('${widget.numero} ${widget.nome}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: C.azul))),
              ]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: C.azul, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.table_chart_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('QUADRAS TRABALHADAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.borda)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _leg(Colors.white, 'Vazio'),
                _leg(const Color(0xFFFFEB99), '1 toque'),
                _leg(const Color(0xFFA8D5A8), '2 toques'),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.borda)),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(11, (linha) {
                    return Row(children: List.generate(14, (col) {
                      if (linha == 0) {
                        final num = (col + 1).toString().padLeft(2, '0');
                        return Container(
                          width: 60, height: 44,
                          decoration: const BoxDecoration(color: C.azulMedio,
                              border: Border(right: BorderSide(color: Colors.white24))),
                          alignment: Alignment.center,
                          child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        );
                      }
                      final e = _q[linha - 1][col];
                      return GestureDetector(
                        onTap: () => _toggle(linha - 1, col),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 60, height: 44,
                          decoration: BoxDecoration(color: _cor(e),
                              border: const Border(right: BorderSide(color: C.borda), bottom: BorderSide(color: C.borda))),
                          alignment: Alignment.center,
                          child: e == 0 ? null : Icon(e == 1 ? Icons.edit : Icons.check, size: 18,
                              color: e == 1 ? C.amarelo : const Color(0xFF2F855A)),
                        ),
                      );
                    }));
                  }),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
  Widget _leg(Color c, String t) => Row(children: [
    Container(width: 18, height: 18, decoration: BoxDecoration(color: c, border: Border.all(color: C.borda), borderRadius: BorderRadius.circular(4))),
    const SizedBox(width: 6),
    Text(t, style: const TextStyle(fontSize: 11, color: C.azul, fontWeight: FontWeight.w600)),
  ]);
}

// ========== SERVIÇO DE CAMPO ==========
class ServicoCampoPage extends StatefulWidget {
  const ServicoCampoPage({super.key});
  @override
  State<ServicoCampoPage> createState() => _ServicoCampoPageState();
}

class _ServicoCampoPageState extends State<ServicoCampoPage> {
  int mes = 9, ano = 2025;
  static const meses = ['JANEIRO','FEVEREIRO','MARÇO','ABRIL','MAIO','JUNHO','JULHO','AGOSTO','SETEMBRO','OUTUBRO','NOVEMBRO','DEZEMBRO'];
  @override
  Widget build(BuildContext context) {
    final nomeMes = meses[mes - 1];
    final pode = AuthStore.instance.podeEditarImportante;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: const Text('SERVIÇO DE CAMPO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.borda)),
              child: Row(children: [
                IconButton(
                  onPressed: () {
                    if (!pode) return;
                    setState(() {
                      mes--;
                      if (mes < 1) { mes = 12; ano--; }
                    });
                  },
                  icon: Icon(Icons.chevron_left, color: pode ? C.azul : C.cinza),
                ),
                Expanded(child: Center(child: Text('$nomeMes $ano',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: C.azul)))),
                IconButton(
                  onPressed: () {
                    if (!pode) return;
                    setState(() {
                      mes++;
                      if (mes > 12) { mes = 1; ano++; }
                    });
                  },
                  icon: Icon(Icons.chevron_right, color: pode ? C.azul : C.cinza),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.bege, borderRadius: BorderRadius.circular(8)),
              child: const Text('Dirigentes atribuídos pela aba DIRIGENTE.',
                  style: TextStyle(fontSize: 11, color: C.azul, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('Grade de Serviço em construção', style: TextStyle(color: C.cinza))),
          ]),
        ),
      ),
    );
  }
}

// ========== DIRIGENTE ==========
class DirigentePage extends StatefulWidget {
  const DirigentePage({super.key});
  @override
  State<DirigentePage> createState() => _DirigentePageState();
}

class _DirigentePageState extends State<DirigentePage> {
  final List<List<TextEditingController>> _ctrl = List.generate(21, (_) => List.generate(3, (_) => TextEditingController()));
  final cab = ['SEGUNDA A SEXTA', 'SÁBADO', 'DOMINGO'];
  @override
  void initState() {
    super.initState();
    for (int c = 0; c < 3; c++) {
      final lista = DirigentesStore.nomes[c];
      for (int i = 0; i < lista.length && i < 20; i++) {
        _ctrl[i + 1][c].text = lista[i];
      }
    }
  }
  @override
  void dispose() {
    for (final l in _ctrl) { for (final c in l) { c.dispose(); } }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: const Text('DIRIGENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: C.azul, borderRadius: BorderRadius.circular(10)),
              child: const Text('GRADE DE DIRIGENTES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.borda)),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(children: List.generate(21, (linha) {
                  return Row(children: List.generate(3, (col) {
                    if (linha == 0) {
                      return Container(
                        width: 140, height: 50,
                        decoration: const BoxDecoration(color: C.azulMedio,
                            border: Border(right: BorderSide(color: Colors.white24), bottom: BorderSide(color: C.azul))),
                        alignment: Alignment.center,
                        child: Text(cab[col], textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      );
                    }
                    return Container(
                      width: 140, height: 50,
                      decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: C.borda), bottom: BorderSide(color: C.borda))),
                      child: TextField(
                        controller: _ctrl[linha][col],
                        textAlign: TextAlign.center,
                        onChanged: (v) => DirigentesStore.setAt(col, linha - 1, v),
                        style: const TextStyle(fontSize: 12, color: C.azul),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 14)),
                      ),
                    );
                  }));
                })),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ========== S.13 ==========
class S13Page extends StatelessWidget {
  const S13Page({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: const Text('S.13', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            const Text('REGISTRO DE DESIGNAÇÃO DE TERRITÓRIO',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Text('Grade em construção...', style: TextStyle(color: C.cinza)),
          ]),
        ),
      ),
    );
  }
}

// ========== EVENTOS ==========
class EventosPage extends StatelessWidget {
  const EventosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: const Text('EVENTOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: const Center(child: Text('Grade de eventos em construção...', style: TextStyle(color: C.cinza))),
      ),
    );
  }
}

// ========== ADMINISTRADOR ==========
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _senha = TextEditingController();
  String _tipo = 'PRINCIPAL';
  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_on);
  }
  @override
  void dispose() {
    AuthStore.instance.removeListener(_on);
    _senha.dispose();
    super.dispose();
  }
  void _on() { if (mounted) setState(() {}); }
  void _entrar() {
    if (AuthStore.instance.login(_tipo, _senha.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logado!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha incorreta'), backgroundColor: Colors.red));
    }
  }
  @override
  Widget build(BuildContext context) {
    final logado = AuthStore.instance.logado;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul, foregroundColor: Colors.white,
        title: const Text('ADMINISTRADOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: logado ? _painel() : _login(),
        ),
      ),
    );
  }
  Widget _login() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.lock_outline, color: C.azul, size: 60),
        const SizedBox(height: 12),
        const Text('Acesso do Administrador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: C.azul)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: C.borda)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _tipo, isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'PRINCIPAL', child: Text('Admin Principal')),
              DropdownMenuItem(value: 'A', child: Text('Admin A')),
              DropdownMenuItem(value: 'B', child: Text('Admin B')),
              DropdownMenuItem(value: 'C', child: Text('Admin C')),
            ],
            onChanged: (v) { if (v != null) setState(() => _tipo = v); },
          )),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _senha, obscureText: true, keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48, width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _entrar,
            icon: const Icon(Icons.login),
            label: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: C.azul, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ]),
    );
  }
  Widget _painel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: C.verde, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Icon(Icons.verified_user, color: Colors.white, size: 60),
        const SizedBox(height: 10),
        Text('Bem-vindo, ${AuthStore.instance.nomeUsuario}',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 48, width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => AuthStore.instance.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
            style: ElevatedButton.styleFrom(backgroundColor: C.vermelho, foregroundColor: Colors.white),
          ),
        ),
      ]),
    );
  }
}
