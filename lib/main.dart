import 'package:flutter/material.dart';

void main() => runApp(const TerritorioApp());

class TerritorioApp extends StatelessWidget {
  const TerritorioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Território de Congregação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class C {
  static const azul = Color(0xFF1A365D);
  static const azulMedio = Color(0xFF2C4A73);
  static const bege = Color(0xFFF3EAD3);
  static const cinza = Color(0xFFA0AEC0);
  static const cinzaClaro = Color(0xFFF0F2F5);
  static const amarelo = Color(0xFFD4A437);
  static const amareloClaro = Color(0xFFFFF3C4);
  static const borda = Color(0xFFD1D5DB);
  static const cinzaForm = Color(0xFFDDDDDD);
  static const verde = Color(0xFF2F855A);
  static const vermelho = Color(0xFFC53030);
}

// =================================================================
// AUTENTICAÇÃO / ADMINISTRADORES
// =================================================================
class AuthStore extends ChangeNotifier {
  static final AuthStore instance = AuthStore._();
  AuthStore._();

  // senha do admin principal (fixa)
  static const String senhaPrincipal = '0000';

  // Admins A, B, C — nome + senha
  final Map<String, String> admins = {
    'A': '0000',
    'B': '0000',
    'C': '0000',
  };

  // quem está logado agora: null | 'PRINCIPAL' | 'A' | 'B' | 'C'
  String? _usuario;
  String? get usuario => _usuario;

  bool get logado => _usuario != null;
  bool get isPrincipal => _usuario == 'PRINCIPAL';
  bool get isAdminABC => _usuario == 'A' || _usuario == 'B' || _usuario == 'C';
  bool get podeEditarImportante => isPrincipal || isAdminABC;

  String get nomeUsuario {
    if (_usuario == null) return 'Visitante';
    if (_usuario == 'PRINCIPAL') return 'Admin Principal';
    return 'Admin $_usuario';
  }

  // tenta login. Retorna true se ok.
  bool login(String tipo, String senha) {
    if (tipo == 'PRINCIPAL') {
      if (senha == senhaPrincipal) {
        _usuario = 'PRINCIPAL';
        notifyListeners();
        return true;
      }
      return false;
    }
    // A, B ou C
    if (admins.containsKey(tipo) && admins[tipo] == senha) {
      _usuario = tipo;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _usuario = null;
    notifyListeners();
  }

  // só o principal pode alterar senha dos A, B, C
  bool alterarSenhaAdmin(String letra, String novaSenha) {
    if (!isPrincipal) return false;
    if (!admins.containsKey(letra)) return false;
    admins[letra] = novaSenha;
    notifyListeners();
    return true;
  }
}

// =================================================================
// APP STATE
// =================================================================
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  DateTime? lastSaved;

  void save() {
    lastSaved = DateTime.now();
    notifyListeners();
  }

  String get lastSavedText {
    if (lastSaved == null) return 'Nunca salvo';
    final d = lastSaved!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} às '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

// =================================================================
// BOTÕES DA APPBAR
// =================================================================
class BotaoSalvar extends StatelessWidget {
  const BotaoSalvar({super.key});

  void _salvar(BuildContext context) {
    AppState.instance.save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Salvo: ${AppState.instance.lastSavedText}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: C.verde,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Salvar',
      icon: const Icon(Icons.save, color: Colors.white),
      onPressed: () => _salvar(context),
    );
  }
}

class BadgeUsuario extends StatelessWidget {
  const BadgeUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthStore.instance,
      builder: (context, _) {
        final logado = AuthStore.instance.logado;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Chip(
            avatar: Icon(
              logado ? Icons.verified_user : Icons.person_outline,
              color: Colors.white,
              size: 14,
            ),
            label: Text(
              AuthStore.instance.nomeUsuario,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: logado ? C.verde : C.cinza,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}

// =================================================================
// STORE DE DESIGNAÇÕES
// =================================================================
class Designacao {
  String nome;
  String dataDesignacao;
  String dataConclusao;

  Designacao({
    this.nome = '',
    this.dataDesignacao = '',
    this.dataConclusao = '',
  });
}

class DesignacaoStore extends ChangeNotifier {
  static final DesignacaoStore instance = DesignacaoStore._();
  DesignacaoStore._();

  final Map<String, List<Designacao>> _dados = {};

  Designacao get(String territorio, int index) {
    final lista = _dados[territorio];
    if (lista == null || index >= lista.length) return Designacao();
    return lista[index];
  }

  void setAll(String territorio, List<Designacao> lista) {
    _dados[territorio] = lista;
    notifyListeners();
  }

  String ultimaDataConclusao(String territorio) {
    final lista = _dados[territorio];
    if (lista == null || lista.isEmpty) return '';

    DateTime? maisRecente;
    String textoMaisRecente = '';

    for (final d in lista) {
      final txt = d.dataConclusao.trim();
      if (txt.isEmpty) continue;
      final data = _parseData(txt);
      if (data == null) continue;
      if (maisRecente == null || data.isAfter(maisRecente)) {
        maisRecente = data;
        textoMaisRecente = txt;
      }
    }
    return textoMaisRecente;
  }

  DateTime? _parseData(String txt) {
    final normalizado = txt.replaceAll('-', '/').replaceAll('.', '/');
    final partes = normalizado.split('/');
    if (partes.length < 2) return null;

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano =
        partes.length >= 3 ? int.tryParse(partes[2]) : DateTime.now().year;

    if (dia == null || mes == null || ano == null) return null;
    if (dia < 1 || dia > 31 || mes < 1 || mes > 12) return null;

    try {
      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }
}

// =================================================================
// STORE DE DIRIGENTES
// =================================================================
class DirigentesStore {
  static List<List<String>> nomes = [
    ['Irmão João Silva', 'Irmão Pedro Santos', 'Irmão Carlos Souza'],
    ['Irmão Marcos Lima', 'Irmão André Costa', 'Irmão Rafael Alves'],
    ['Irmão Lucas Pereira', 'Irmão Mateus Rocha', 'Irmão Tiago Ribeiro'],
  ];

  static List<String> validos(int coluna) {
    return nomes[coluna]
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  static void setAt(int coluna, int index, String valor) {
    while (nomes[coluna].length <= index) {
      nomes[coluna].add('');
    }
    nomes[coluna][index] = valor;
  }
}

// =================================================================
// HOME
// =================================================================
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
        title: const Text(
          'Início',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildInfoSalvamento(),
                    const SizedBox(height: 12),
                    _buildPermissaoInfo(),
                    const SizedBox(height: 16),
                    _buildGrid(),
                    const SizedBox(height: 20),
                    _buildSecaoMapa(),
                    const SizedBox(height: 16),
                    _buildSecaoNotas(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: C.azul,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Território de Congregação',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissaoInfo() {
    final pode = AuthStore.instance.podeEditarImportante;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: pode ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pode ? const Color(0xFFA8D5A8) : C.amarelo.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            pode ? Icons.lock_open : Icons.lock_outline,
            color: pode ? C.verde : C.amarelo,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pode
                      ? 'Você tem permissão de administrador'
                      : 'Modo visitante (edição limitada)',
                  style: TextStyle(
                    fontSize: 12,
                    color: pode ? C.verde : C.amarelo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pode
                      ? 'Pode editar todas as partes do app'
                      : 'Só as grades DIRIGENTE e QUADRAS são editáveis',
                  style: const TextStyle(fontSize: 11, color: C.azul),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSalvamento() {
    final salvo = AppState.instance.lastSaved != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: salvo ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: salvo ? const Color(0xFFA8D5A8) : C.amarelo.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            salvo ? Icons.cloud_done : Icons.cloud_off,
            color: salvo ? C.verde : C.amarelo,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salvo ? 'Último salvamento' : 'Nenhum salvamento ainda',
                  style: TextStyle(
                    fontSize: 11,
                    color: salvo ? C.verde : C.amarelo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppState.instance.lastSavedText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: C.azul,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final items = [
      {'icon': Icons.map_outlined, 'label': 'Territórios', 'acao': 'territorios'},
      {'icon': Icons.menu_book_outlined, 'label': 'Serviço de Campo', 'acao': 'servico'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Eventos', 'acao': 'eventos'},
      {'icon': Icons.person_pin_circle_outlined, 'label': 'Dirigente', 'acao': 'dirigente'},
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
      itemBuilder: (context, index) {
        return _buildCardMenu(
          icon: items[index]['icon'] as IconData,
          label: items[index]['label'] as String,
          acao: items[index]['acao'] as String,
        );
      },
    );
  }

  Widget _buildCardMenu({
    required IconData icon,
    required String label,
    required String acao,
  }) {
    return Material(
      color: C.bege,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (acao == 'territorios') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TerritoriosPage()));
          } else if (acao == 'servico') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ServicoCampoPage()));
          } else if (acao == 'dirigente') {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DirigentePage()));
          } else if (acao == 's13') {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const S13Page()));
          } else if (acao == 'eventos') {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EventosPage()));
          } else if (acao == 'admin') {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AdminPage()));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: C.azul),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: C.azul,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoMapa() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTituloSecao('Visão Geral do Território'),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: C.bege,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.map_outlined,
                      size: 60, color: C.cinza.withOpacity(0.6)),
                ),
                const Positioned(
                    top: 25,
                    left: 40,
                    child: Icon(Icons.location_on, color: C.azul, size: 28)),
                const Positioned(
                    top: 70,
                    right: 80,
                    child: Icon(Icons.location_on,
                        color: C.amarelo, size: 24)),
                const Positioned(
                    bottom: 20,
                    right: 40,
                    child: Icon(Icons.location_on, color: C.azul, size: 28)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoNotas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTituloSecao('Notas recentes do serviço'),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma nota recente...',
            style: TextStyle(
              color: C.cinza,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloSecao(String titulo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: C.azul,
          ),
        ),
        const Icon(Icons.chevron_right, color: C.cinza),
      ],
    );
  }

  Widget _buildBottomNav() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = index == _abaAtual;
          return InkWell(
            onTap: () => setState(() => _abaAtual = index),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: isActive ? C.azul : C.cinza,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? C.azul : C.cinza,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =================================================================
// TERRITÓRIOS
// =================================================================
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
            letterSpacing: 0.5,
          ),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalheTerritorioPage(
                        numero: t['numero']!,
                        nome: t['nome']!,
                      ),
                    ),
                  );
                },
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
                            color: C.azul,
                          ),
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

// =================================================================
// DETALHE DO TERRITÓRIO
// =================================================================
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
    AuthStore.instance.addListener(_onAuthChanged);
    for (int linha = 1; linha <= 4; linha++) {
      _dirigenteControllers[linha][colDirigente]
          .addListener(_rebuildDesignacoes);
      _dirigenteControllers[linha][colDataInicial]
          .addListener(_rebuildDesignacoes);
      _dirigenteControllers[linha][colDataFinal]
          .addListener(_rebuildDesignacoes);
    }
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuthChanged);
    for (final linha in _dirigenteControllers) {
      for (final c in linha) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _rebuildDesignacoes() {
    final lista = <Designacao>[];

    for (int linha = 1; linha <= 4; linha++) {
      final nome = _dirigenteControllers[linha][colDirigente].text.trim();
      final dataIni =
          _dirigenteControllers[linha][colDataInicial].text.trim();
      final dataFim = _dirigenteControllers[linha][colDataFinal].text.trim();

      if (nome.isNotEmpty && dataIni.isNotEmpty) {
        lista.add(Designacao(
          nome: nome,
          dataDesignacao: dataIni,
          dataConclusao: dataFim,
        ));
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

  void _alternarCelula(int linha, int coluna) {
    setState(() {
      _quadrasEstados[linha][coluna] = (_quadrasEstados[linha][coluna] + 1) % 3;
    });
  }

  Color _corCelula(int estado) {
    switch (estado) {
      case 1:
        return const Color(0xFFFFEB99);
      case 2:
        return const Color(0xFFA8D5A8);
      default:
        return Colors.white;
    }
  }

  void _abrirOpcoesFoto() {
    // só admins podem alterar foto do mapa
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
      builder: (context) {
        return SafeArea(
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Foto do mapa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: C.azul,
                  ),
                ),
                const SizedBox(height: 20),
                _opcaoFoto(Icons.photo_library_outlined,
                    'Escolher da galeria', () {
                  Navigator.pop(context);
                  setState(() {
                    _fotoMapa =
                        'https://picsum.photos/seed/${widget.numero}/600/500';
                  });
                }),
                const SizedBox(height: 8),
                _opcaoFoto(Icons.camera_alt_outlined, 'Tirar foto', () {
                  Navigator.pop(context);
                  setState(() {
                    _fotoMapa =
                        'https://picsum.photos/seed/${widget.numero}/600/500';
                  });
                }),
                if (_fotoMapa != null) ...[
                  const SizedBox(height: 8),
                  _opcaoFoto(Icons.delete_outline, 'Remover foto', () {
                    Navigator.pop(context);
                    setState(() => _fotoMapa = null);
                  }, cor: Colors.red),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _opcaoFoto(IconData icon, String label, VoidCallback onTap,
      {Color? cor}) {
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cor ?? C.azul,
                ),
              ),
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
        title: Text(
          widget.numero,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardNome() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
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
                color: C.azul,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _areaFoto() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
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
  }

  Widget _botaoFoto() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _abrirOpcoesFoto,
        icon: Icon(
          _fotoMapa != null ? Icons.edit : Icons.add_a_photo_outlined,
          size: 18,
        ),
        label: Text(
          _fotoMapa != null ? 'Alterar foto do mapa' : 'Adicionar foto do mapa',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: C.azul,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _tituloGrade(String titulo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.azul,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_chart_outlined,
              color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoIntegracao() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.bege,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.link, color: C.azul, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Quem INICIA (nome + data inicial) cria um bloco novo. Quem CONCLUI só preenche a data final e fecha o bloco aberto.',
              style: TextStyle(
                fontSize: 11,
                color: C.azul,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _itemLegenda(Colors.white, 'Vazio'),
          _itemLegenda(const Color(0xFFFFEB99), '1 toque'),
          _itemLegenda(const Color(0xFFA8D5A8), '2 toques'),
        ],
      ),
    );
  }

  Widget _itemLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: cor,
            border: Border.all(color: C.borda),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 11,
            color: C.azul,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
                      border:
                          Border(right: BorderSide(color: Colors.white24)),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _cabecalhoDirigente[coluna],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                final bool destacada = (coluna == colDirigente ||
                    coluna == colDataInicial ||
                    coluna == colDataFinal) &&
                    linha <= 4;
                return Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: destacada
                        ? const Color(0xFFFFF7DC)
                        : Colors.white,
                    border: const Border(
                      right: BorderSide(color: C.borda),
                      bottom: BorderSide(color: C.borda),
                    ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(11, (linha) {
            return Row(
              children: List.generate(14, (coluna) {
                if (linha == 0) {
                  final numero = (coluna + 1).toString().padLeft(2, '0');
                  return Container(
                    width: w,
                    height: h,
                    decoration: const BoxDecoration(
                      color: C.azulMedio,
                      border:
                          Border(right: BorderSide(color: Colors.white24)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      numero,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
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
                            color: estado == 1
                                ? C.amarelo
                                : const Color(0xFF2F855A),
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
}

// =================================================================
// SERVIÇO DE CAMPO
// =================================================================
class ServicoCampoPage extends StatefulWidget {
  const ServicoCampoPage({super.key});

  @override
  State<ServicoCampoPage> createState() => _ServicoCampoPageState();
}

class _ServicoCampoPageState extends State<ServicoCampoPage> {
  static const double wMes = 65;
  static const double wSemana = 80;
  static const double wLocal = 130;
  static const double wHorario = 75;
  static const double wDirigente = 150;
  static const double hLinha = 44;

  static const List<String> _nomesMeses = [
    'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
    'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO',
  ];

  int _ano = 2025;
  int _mes = 9;

  late List<_LinhaServico> _linhas;

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuthChanged);
    _linhas = _gerarLinhas(_ano, _mes);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  List<_LinhaServico> _gerarLinhas(int ano, int mes) {
    final linhas = <_LinhaServico>[];
    const nomesSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    int idxSegASex = 0;
    int idxSab = 0;
    int idxDom = 0;

    final ultimoDia = DateTime(ano, mes + 1, 0).day;

    for (int dia = 1; dia <= ultimoDia; dia++) {
      final data = DateTime(ano, mes, dia);
      final diaSemana = data.weekday;

      String horario = '08:30';
      if (diaSemana == DateTime.thursday) horario = '17:30';
      if (ano >= 2026 && diaSemana == DateTime.wednesday) {
        horario = '17:30';
      }

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

      linhas.add(_LinhaServico(
        mes: '${dia.toString().padLeft(2, '0')}/${mes.toString().padLeft(2, '0')}',
        semana: nomesSemana[diaSemana - 1],
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
        title: const Text(
          'SERVIÇO DE CAMPO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
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
                            letterSpacing: 0.5,
                          ),
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
                    Icon(
                      pode ? Icons.info_outline : Icons.lock,
                      color: pode ? C.azul : C.vermelho,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pode
                            ? 'Dirigentes atribuídos automaticamente pela aba DIRIGENTE.'
                            : 'Somente administradores podem editar esta tela.',
                        style: TextStyle(
                          fontSize: 11,
                          color: pode ? C.azul : C.vermelho,
                          fontWeight: FontWeight.w600,
                        ),
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
                      ...List.generate(_linhas.length, (i) {
                        return _linha(i, _linhas[i], pode);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      color: C.azulMedio,
      child: Row(
        children: [
          _celCabecalho('MÊS', wMes),
          _celCabecalho('SEMANA', wSemana),
          _celCabecalho('LOCAL', wLocal),
          _celCabecalho('HORÁRIO', wHorario),
          _celCabecalho('DIRIGENTE', wDirigente),
        ],
      ),
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
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _linha(int i, _LinhaServico l, bool pode) {
    final isPar = i.isEven;
    return Container(
      color: isPar ? Colors.white : const Color(0xFFF9FAFB),
      child: Row(
        children: [
          _celTexto(l.mes, wMes, bold: true),
          _celTexto(l.semana, wSemana),
          _celEditavel(wLocal, 'Local', (v) => l.local = v, pode),
          _celHorario(l.horario, wHorario),
          _celDirigente(l.dirigente, wDirigente),
        ],
      ),
    );
  }

  Widget _celTexto(String texto, double largura, {bool bold = false}) {
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
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          color: C.azul,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _celHorario(String horario, double largura) {
    final isTarde = horario == '17:30';
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isTarde ? C.bege : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          horario,
          style: const TextStyle(
            fontSize: 12,
            color: C.azul,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _celEditavel(double largura, String hint,
      ValueChanged<String> onChanged, bool pode) {
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
        style: TextStyle(
          fontSize: 12,
          color: pode ? C.azul : C.cinza,
        ),
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

  Widget _celDirigente(String nome, double largura) {
    final vazio = nome.isEmpty;
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
      child: Text(
        vazio ? '—' : nome,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          color: vazio ? C.cinza : C.azul,
          fontWeight: vazio ? FontWeight.normal : FontWeight.w600,
        ),
      ),
    );
  }
}

// =================================================================
// DIRIGENTE (sempre editável)
// =================================================================
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

  static const double larguraColuna = 140;
  static const double alturaLinha = 50;

  @override
  void initState() {
    super.initState();
    for (int coluna = 0; coluna < totalColunas; coluna++) {
      final lista = DirigentesStore.nomes[coluna];
      for (int i = 0; i < lista.length && i < (totalLinhas - 1); i++) {
        _controllers[i + 1][coluna].text = lista[i];
      }
    }
  }

  @override
  void dispose() {
    for (final linha in _controllers) {
      for (final c in linha) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _atualizarStore(int linha, int coluna, String valor) {
    DirigentesStore.setAt(coluna, linha - 1, valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DIRIGENTE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.table_chart_outlined,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'GRADE DE DIRIGENTES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: C.bege,
                  borderRadius: BorderRadius.circular(8),
                ),
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
                          fontWeight: FontWeight.w600,
                        ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(totalLinhas, (linha) {
                      return Row(
                        children: List.generate(totalColunas, (coluna) {
                          if (linha == 0) {
                            return Container(
                              width: larguraColuna,
                              height: alturaLinha,
                              decoration: const BoxDecoration(
                                color: C.azulMedio,
                                border: Border(
                                  right: BorderSide(color: Colors.white24),
                                  bottom: BorderSide(color: C.azul),
                                ),
                              ),
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                _cabecalho[coluna],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: larguraColuna,
                            height: alturaLinha,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: C.borda),
                                bottom: BorderSide(color: C.borda),
                              ),
                            ),
                            child: TextField(
                              controller: _controllers[linha][coluna],
                              textAlign: TextAlign.center,
                              onChanged: (v) =>
                                  _atualizarStore(linha, coluna, v),
                              style: const TextStyle(
                                fontSize: 12,
                                color: C.azul,
                                fontWeight: FontWeight.w500,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// S.13
// =================================================================
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
    AuthStore.instance.addListener(_onAuthChanged);
    DesignacaoStore.instance.addListener(_sincronizar);
    _sincronizar();
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuthChanged);
    DesignacaoStore.instance.removeListener(_sincronizar);
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

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _sincronizar() {
    if (!mounted) return;
    setState(() {
      for (int linha = 0; linha < totalLinhas; linha++) {
        final terrNum = 'T-${linha + 1}';

        if (_terr[linha].text != terrNum) {
          _terr[linha].text = terrNum;
        }

        final ultima = DesignacaoStore.instance.ultimaDataConclusao(terrNum);
        if (_ultima[linha].text != ultima) {
          _ultima[linha].text = ultima;
        }

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

  @override
  Widget build(BuildContext context) {
    final pode = AuthStore.instance.podeEditarImportante;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'S.13 — REGISTRO DE DESIGNAÇÃO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
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
                child: Text(
                  'REGISTRO DE DESIGNAÇÃO DE TERRITÓRIO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: C.bege,
                  borderRadius: BorderRadius.circular(8),
                ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Ano de Serviço: ',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _anoServico,
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
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      ...List.generate(totalLinhas,
                          (linha) => _buildDataRow(linha)),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cellHeader('Terr.\nn.º', wTerr, hHeader1 + hHeader2),
        _cellHeader('Última data\nconcluída*', wUltima, hHeader1 + hHeader2),
        ...List.generate(totalBlocos, (i) {
          return SizedBox(
            width: wBloco,
            child: Column(
              children: [
                _cellHeader('Designado para', wBloco, hHeader1),
                Row(
                  children: [
                    _cellHeader('Data da\ndesignação', wData, hHeader2),
                    _cellHeader('Data da\nconclusão', wData, hHeader2),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDataRow(int linha) {
    return Row(
      children: [
        _cellAuto(_terr[linha], wTerr, hLinha),
        _cellAuto(_ultima[linha], wUltima, hLinha,
            corFundo: const Color(0xFFFFF7DC), negrito: true),
        ...List.generate(totalBlocos, (bloco) {
          return _blocoDesignado(linha, bloco);
        }),
      ],
    );
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
      child: Column(
        children: [
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black)),
                    ),
                    child: _cellAutoConteudo(_blocos[linha][bloco][1]),
                  ),
                ),
                Expanded(
                  child: _cellAutoConteudo(_blocos[linha][bloco][2]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellAuto(
    TextEditingController c,
    double w,
    double h, {
    Color? corFundo,
    bool negrito = false,
  }) {
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
        builder: (context, _) {
          return Text(
            c.text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: negrito ? FontWeight.bold : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  Widget _cellAutoConteudo(TextEditingController c) {
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            c.text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

// =================================================================
// EVENTOS
// =================================================================
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
    AuthStore.instance.addListener(_onAuthChanged);
    _dias = List.generate(
        totalLinhas, (_) => List.generate(totalGrupos, (_) => 0));
    _pg = List.generate(
        totalLinhas, (_) => List.generate(totalGrupos, (_) => false));
    _nomes = List.generate(
      totalLinhas,
      (_) => List.generate(
        totalGrupos,
        (_) => TextEditingController(),
      ),
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuthChanged);
    for (final linha in _nomes) {
      for (final c in linha) {
        c.dispose();
      }
    }
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  bool _match(int linha, int grupo) {
    if (_query.isEmpty) return false;
    final nome = _nomes[linha][grupo].text.toLowerCase();
    return nome.contains(_query);
  }

  int _contarResultados() {
    if (_query.isEmpty) return 0;
    int total = 0;
    for (int l = 0; l < totalLinhas; l++) {
      for (int g = 0; g < totalGrupos; g++) {
        if (_match(l, g)) total++;
      }
    }
    return total;
  }

  String _numero(int linha, int grupo) {
    final numero = (grupo * totalLinhas) + linha + 1;
    return numero.toString().padLeft(2, '0');
  }

  void _toggleDia(int linha, int grupo, int bit) {
    if (!AuthStore.instance.podeEditarImportante) {
      _avisarSemPermissao();
      return;
    }
    setState(() {
      _dias[linha][grupo] ^= bit;
    });
  }

  void _togglePg(int linha, int grupo) {
    if (!AuthStore.instance.podeEditarImportante) {
      _avisarSemPermissao();
      return;
    }
    setState(() {
      _pg[linha][grupo] = !_pg[linha][grupo];
    });
  }

  void _avisarSemPermissao() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apenas administradores podem editar esta tela.'),
        backgroundColor: C.vermelho,
        duration: Duration(seconds: 1),
      ),
    );
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
            : const Text(
                'EVENTOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _searchAtivo ? 'Fechar busca' : 'Pesquisar',
            icon: Icon(_searchAtivo ? Icons.close : Icons.search,
                color: Colors.white),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_query.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
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
                          _contarResultados() == 0
                              ? 'Nenhum resultado para "$_query"'
                              : '${_contarResultados()} resultado(s) para "$_query"',
                          style: const TextStyle(
                            fontSize: 12,
                            color: C.azul,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: pode ? C.bege : const Color(0xFFFFE0E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        pode ? Icons.info_outline : Icons.lock,
                        color: pode ? C.azul : C.vermelho,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pode
                              ? 'Marque os dias (SEX/SÁB/DOM) e o pagamento (PG). Use a lupa para pesquisar.'
                              : 'Somente administradores podem marcar dias/pagamento.',
                          style: TextStyle(
                            fontSize: 11,
                            color: pode ? C.azul : C.vermelho,
                            fontWeight: FontWeight.w600,
                          ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCabecalho(),
                      ...List.generate(
                        totalLinhas,
                        (linha) => _buildLinha(linha, pode),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCabecalho() {
    return Container(
      color: C.azulMedio,
      child: Row(
        children: List.generate(totalGrupos, (grupo) {
          return Row(
            children: [
              _celCabecalho('Nº', wN),
              _celCabecalho('NOME', wNome),
              _celCabecalho('DIAS', wDias),
              _celCabecalho('PG', wPg),
            ],
          );
        }),
      ),
    );
  }

  Widget _celCabecalho(String texto, double largura) {
    return Container(
      width: largura,
      height: hHeader,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white24)),
      ),
      alignment: Alignment.center,
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildLinha(int linha, bool pode) {
    final isPar = linha.isEven;
    return Container(
      color: isPar ? Colors.white : const Color(0xFFF9FAFB),
      child: Row(
        children: List.generate(totalGrupos, (grupo) {
          return Row(
            children: [
              _celNumero(linha, grupo),
              _celNome(linha, grupo, pode),
              _celDias(linha, grupo),
              _celPg(linha, grupo),
            ],
          );
        }),
      ),
    );
  }

  Widget _celNumero(int linha, int grupo) {
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
      child: Text(
        _numero(linha, grupo),
        style: const TextStyle(
          fontSize: 12,
          color: C.azul,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _celNome(int linha, int grupo, bool pode) {
    final destacada = _match(linha, grupo);
    return Container(
      width: wNome,
      height: hLinha,
      decoration: BoxDecoration(
        color: destacada ? C.amareloClaro : Colors.transparent,
        border: Border(
          right: const BorderSide(color: C.borda),
          bottom: const BorderSide(color: C.borda),
          top: destacada
              ? const BorderSide(color: C.amarelo, width: 2)
              : BorderSide.none,
          left: destacada
              ? const BorderSide(color: C.amarelo, width: 2)
              : BorderSide.none,
        ),
      ),
      child: TextField(
        controller: _nomes[linha][grupo],
        textAlign: TextAlign.center,
        readOnly: !pode,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 11,
          color: pode ? C.azul : C.cinza,
          fontWeight: destacada ? FontWeight.bold : FontWeight.normal,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
      ),
    );
  }

  Widget _celDias(int linha, int grupo) {
    return Container(
      width: wDias,
      height: hLinha,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: C.borda),
          bottom: BorderSide(color: C.borda),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _botaoDia(linha, grupo, 1, 'SEX'),
          const SizedBox(width: 3),
          _botaoDia(linha, grupo, 2, 'SÁB'),
          const SizedBox(width: 3),
          _botaoDia(linha, grupo, 4, 'DOM'),
        ],
      ),
    );
  }

  Widget _botaoDia(int linha, int grupo, int bit, String label) {
    final ativo = (_dias[linha][grupo] & bit) != 0;
    return GestureDetector(
      onTap: () => _toggleDia(linha, grupo, bit),
      child: Container(
        width: 28,
        height: 30,
        decoration: BoxDecoration(
          color: ativo ? C.verde : const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: ativo ? C.verde : C.borda,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: ativo ? Colors.white : C.azul,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _celPg(int linha, int grupo) {
    final pago = _pg[linha][grupo];
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
        onTap: () => _togglePg(linha, grupo),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: pago ? C.verde : const Color(0xFFFFE0E0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: pago ? C.verde : Colors.red.shade300,
            ),
          ),
          child: Text(
            pago ? 'PAGO' : 'N/PG',
            style: TextStyle(
              fontSize: 9,
              color: pago ? Colors.white : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// ADMINISTRADOR
// =================================================================
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
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
        title: const Text(
          'ADMINISTRADOR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AuthStore.instance.logado
              ? _buildPainelLogado()
              : _buildLogin(),
        ),
      ),
    );
  }

  // ===== TELA DE LOGIN =====
  Widget _buildLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.lock_outline, color: C.azul, size: 60),
              const SizedBox(height: 12),
              const Text(
                'Acesso do Administrador',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: C.azul,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Somente administradores podem editar partes importantes do app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: C.cinza),
              ),
              const SizedBox(height: 20),
              _buildLoginForm(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildRegrasPermissao(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return _LoginForm();
  }

  Widget _buildRegrasPermissao() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.bege,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissões',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: C.azul,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          _ItemPermissao(
            icon: Icons.verified_user,
            texto: 'Admin Principal: cadastra A, B, C e edita tudo',
          ),
          SizedBox(height: 6),
          _ItemPermissao(
            icon: Icons.admin_panel_settings,
            texto: 'Admins A, B, C: editam partes importantes',
          ),
          SizedBox(height: 6),
          _ItemPermissao(
            icon: Icons.person_outline,
            texto: 'Visitante: só edita DIRIGENTE e QUADRAS',
          ),
        ],
      ),
    );
  }

  // ===== PAINEL DE QUEM ESTÁ LOGADO =====
  Widget _buildPainelLogado() {
    final u = AuthStore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.verde,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.verified_user, color: Colors.white, size: 60),
              const SizedBox(height: 10),
              Text(
                'Bem-vindo, ${u.nomeUsuario}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                u.isPrincipal
                    ? 'Você pode cadastrar admins A, B e C'
                    : 'Você pode editar as partes importantes do app',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Se for o principal, mostra cadastro de admins
        if (u.isPrincipal) ...[
          _buildCadastroAdmins(),
          const SizedBox(height: 16),
        ],

        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              AuthStore.instance.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sessão encerrada'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text(
              'Sair',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.vermelho,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCadastroAdmins() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.group_add, color: C.azul, size: 22),
              SizedBox(width: 8),
              Text(
                'Cadastro de Admins (A, B, C)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: C.azul,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final letra in ['A', 'B', 'C'])
            _LinhaAdmin(letra: letra),
        ],
      ),
    );
  }
}

// ===== LINHA DE CADASTRO DE UM ADMIN =====
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: C.azul,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.letra,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
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
            tooltip: 'Salvar senha',
            icon: const Icon(Icons.check_circle, color: C.verde),
            onPressed: () {
              final nova = _ctrl.text.trim();
              if (nova.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A senha não pode estar vazia'),
                    backgroundColor: C.vermelho,
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }
              final ok = AuthStore.instance.alterarSenhaAdmin(
                  widget.letra, nova);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Senha do admin ${widget.letra} atualizada'
                      : 'Não foi possível atualizar'),
                  backgroundColor: ok ? C.verde : C.vermelho,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===== FORMULÁRIO DE LOGIN =====
class _LoginForm extends StatefulWidget {
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
    final senha = _senha.text.trim();
    if (senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite a senha'),
          backgroundColor: C.vermelho,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final ok = AuthStore.instance.login(_tipo, senha);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha incorreta'),
          backgroundColor: C.vermelho,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Entrar como:',
          style: TextStyle(fontSize: 12, color: C.cinza),
        ),
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
                DropdownMenuItem(
                    value: 'PRINCIPAL', child: Text('Admin Principal')),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            label: const Text(
              'Entrar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===== ITEM DE PERMISSÃO =====
class _ItemPermissao extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _ItemPermissao({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: C.azul, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 12, color: C.azul),
          ),
        ),
      ],
    );
  }
}

// ===== MODELO AUXILIAR =====
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
