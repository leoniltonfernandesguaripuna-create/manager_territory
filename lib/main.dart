import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'cloud.dart';
import 'tema.dart';     
import 'stores.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Cloud.iniciar();
  await _carregarDados();
  runApp(const TerritorioApp());
}

Future<void> _carregarDados() async {
  if (!Cloud.disponivel) return;
  try {
    final terr = await Cloud.ler('territorios');
    if (terr != null && terr['lista'] != null) {
      TerritoriosStore.instance.carregar(List<Map<String, dynamic>>.from(
        (terr['lista'] as List).map((e) => Map<String, dynamic>.from(e)),
      ));
    }
    final desig = await Cloud.ler('designacoes');
    if (desig != null && desig['dados'] != null) {
      DesignacaoStore.instance.carregar(Map<String, dynamic>.from(desig['dados']));
    }
    final obs = await Cloud.ler('observacoes');
    if (obs != null && obs['dados'] != null) {
      ObsStore.instance.carregar(Map<String, dynamic>.from(obs['dados']));
    }
    final dir = await Cloud.ler('dirigentes');
    if (dir != null && dir['nomes'] != null) {
      final nomesMap = Map<String, dynamic>.from(dir['nomes'] as Map);
      final lista = List<List<String>>.generate(
        3,
        (i) => List<String>.from(nomesMap['$i'] ?? []),
      );
      DirigentesStore.carregar(lista);
    }
    final adm = await Cloud.ler('admins');
    if (adm != null && adm['senhas'] != null) {
      AuthStore.instance.carregarAdmins(Map<String, String>.from(adm['senhas']));
    }
    final sc = await Cloud.ler('servico_campo');
    if (sc != null && sc['locais'] != null) {
      ServicoCampoStore.instance.carregar(Map<String, dynamic>.from(sc['locais']));
    }
    final ev = await Cloud.ler('eventos');
    if (ev != null && ev['dados'] != null) {
      EventosStore.instance.carregar(Map<String, dynamic>.from(ev['dados']));
    }
    final mapas = await Cloud.ler('mapas');
    if (mapas != null) {
      MapasStore.carregar(mapas);
    }
    final quadras = await Cloud.ler('quadras');
    if (quadras != null) {
      QuadrasStore.carregar(quadras);
    }
    final dirTerr = await Cloud.ler('dirigentes_territorio');
    if (dirTerr != null) {
      DirigenteTerritorioStore.carregar(dirTerr);
    }
  } catch (_) {}
}

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


// ============== AUTH STORE ==============
class AuthStore extends ChangeNotifier {
  static final AuthStore instance = AuthStore._();
  AuthStore._();
  static const String senhaPrincipal = '0000';
  final Map<String, String> admins = {'A': '0000', 'B': '0000', 'C': '0000'};
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
  bool login(String tipo, String senha) {
    if (tipo == 'PRINCIPAL') {
      if (senha == senhaPrincipal) {
        _usuario = 'PRINCIPAL';
        notifyListeners();
        return true;
      }
      return false;
    }
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
  bool alterarSenhaAdmin(String letra, String novaSenha) {
    if (!isPrincipal) return false;
    if (!admins.containsKey(letra)) return false;
    admins[letra] = novaSenha;
    notifyListeners();
    Cloud.salvar('admins', {'senhas': admins});
    return true;
  }
  void carregarAdmins(Map<String, String> dados) {
    admins.clear();
    admins.addAll(dados);
    notifyListeners();
  }
}

// ============== APP STATE ==============
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

// ============== TERRITÓRIO ==============
class Territorio {
  String numero;
  String nome;
  Territorio({required this.numero, required this.nome});
  Map<String, dynamic> toJson() => {'numero': numero, 'nome': nome};
  factory Territorio.fromJson(Map<String, dynamic> j) => Territorio(
        numero: j['numero']?.toString() ?? '',
        nome: j['nome']?.toString() ?? '',
      );
}

class TerritoriosStore extends ChangeNotifier {
  static final TerritoriosStore instance = TerritoriosStore._();
  TerritoriosStore._();
  final List<Territorio> lista = [
    Territorio(numero: 'T-1', nome: 'St Terezinha 1'),
    Territorio(numero: 'T-2', nome: 'St Terezinha 2'),
    Territorio(numero: 'T-3', nome: 'Fantinato 1'),
    Territorio(numero: 'T-4', nome: 'Fantinato 2'),
    Territorio(numero: 'T-5', nome: 'Fantinato 3'),
    Territorio(numero: 'T-6', nome: 'Jd Vitória'),
    Territorio(numero: 'T-7', nome: 'Chaparral 1'),
    Territorio(numero: 'T-8', nome: 'Chaparral 2'),
    Territorio(numero: 'T-9', nome: 'Centro'),
    Territorio(numero: 'T-10', nome: 'Vila Nova'),
    Territorio(numero: 'T-11', nome: 'Boa Esperança'),
    Territorio(numero: 'T-12', nome: 'Santa Rita'),
    Territorio(numero: 'T-13', nome: 'São José'),
    Territorio(numero: 'T-14', nome: 'Ipê Amarelo'),
  ];
  void renomear(int index, String novoNome) {
    lista[index].nome = novoNome;
    notifyListeners();
    _salvar();
  }
  void carregar(List<Map<String, dynamic>> dados) {
    if (dados.isEmpty) return;
    lista.clear();
    for (final d in dados) {
      lista.add(Territorio.fromJson(d));
    }
    notifyListeners();
  }
  Future<void> _salvar() async {
    await Cloud.salvar('territorios', {
      'lista': lista.map((t) => t.toJson()).toList(),
    });
  }
}

// ============== DESIGNAÇÃO ==============
class Designacao {
  String nome;
  String dataDesignacao;
  String dataConclusao;
  Designacao({this.nome = '', this.dataDesignacao = '', this.dataConclusao = ''});
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'dataDesignacao': dataDesignacao,
        'dataConclusao': dataConclusao,
      };
  factory Designacao.fromJson(Map<String, dynamic> j) => Designacao(
        nome: j['nome']?.toString() ?? '',
        dataDesignacao: j['dataDesignacao']?.toString() ?? '',
        dataConclusao: j['dataConclusao']?.toString() ?? '',
      );
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

  void set(String territorio, int index, Designacao d) {
    _dados.putIfAbsent(territorio, () => []);
    while (_dados[territorio]!.length <= index) {
      _dados[territorio]!.add(Designacao());
    }
    _dados[territorio]![index] = d;
    notifyListeners();
    _salvar();
  }

  void limparTudo() {
    _dados.clear();
    notifyListeners();
    _salvar();
  }

  void carregar(Map<String, dynamic> dados) {
    _dados.clear();
    dados.forEach((key, value) {
      final lista = (value as List)
          .map((e) => Designacao.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _dados[key] = lista;
    });
    notifyListeners();
  }

  Future<void> _salvar() async {
    final out = <String, dynamic>{};
    _dados.forEach((k, v) {
      out[k] = v.map((d) => d.toJson()).toList();
    });
    await Cloud.salvar('designacoes', {'dados': out});
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
    final n = txt.replaceAll('-', '/').replaceAll('.', '/');
    final p = n.split('/');
    if (p.length < 2) return null;
    final dia = int.tryParse(p[0]);
    final mes = int.tryParse(p[1]);
    final ano = p.length >= 3 ? int.tryParse(p[2]) : DateTime.now().year;
    if (dia == null || mes == null || ano == null) return null;
    if (dia < 1 || dia > 31 || mes < 1 || mes > 12) return null;
    try {
      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }
}

// ============== OBSERVAÇÕES ==============
class ObsStore extends ChangeNotifier {
  static final ObsStore instance = ObsStore._();
  ObsStore._();
  final Map<String, String> _obs = {};
  String get(String territorio) => _obs[territorio] ?? '';
  void set(String territorio, String texto) {
    _obs[territorio] = texto;
    notifyListeners();
    _salvar();
  }
  void carregar(Map<String, dynamic> dados) {
    _obs.clear();
    dados.forEach((k, v) => _obs[k] = v.toString());
    notifyListeners();
  }
  Future<void> _salvar() async {
    await Cloud.salvar('observacoes', {'dados': _obs});
  }
}

// ============== DIRIGENTES ==============
class DirigentesStore {
  static List<List<String>> nomes = [
    ['Irmão João Silva', 'Irmão Pedro Santos', 'Irmão Carlos Souza'],
    ['Irmão Marcos Lima', 'Irmão André Costa', 'Irmão Rafael Alves'],
    ['Irmão Lucas Pereira', 'Irmão Mateus Rocha', 'Irmão Tiago Ribeiro'],
  ];
  static List<String> validos(int coluna) {
    return nomes[coluna].map((n) => n.trim()).where((n) => n.isNotEmpty).toList();
  }
  static void setAt(int coluna, int index, String valor) {
    while (nomes[coluna].length <= index) {
      nomes[coluna].add('');
    }
    nomes[coluna][index] = valor;
    final nomesMap = <String, dynamic>{};
    for (int i = 0; i < nomes.length; i++) {
      nomesMap['$i'] = nomes[i];
    }
    Cloud.salvar('dirigentes', {'nomes': nomesMap});
  }
  static void carregar(List<List<String>> dados) {
    if (dados.isEmpty) return;
    nomes = dados;
  }
}

// ============== SERVIÇO DE CAMPO STORE ==============
class ServicoCampoStore extends ChangeNotifier {
  static final ServicoCampoStore instance = ServicoCampoStore._();
  ServicoCampoStore._();
  final Map<String, String> locais = {};
  Timer? _debounce;

  void setLocal(String dataKey, String valor) {
    locais[dataKey] = valor;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _salvar);
  }

  void carregar(Map<String, dynamic> dados) {
    locais.clear();
    dados.forEach((k, v) => locais[k] = v.toString());
    notifyListeners();
  }

  Future<void> _salvar() async {
    await Cloud.salvar('servico_campo', {'locais': locais});
  }
}

// ============== EVENTOS STORE ==============
class EventosStore extends ChangeNotifier {
  static final EventosStore instance = EventosStore._();
  EventosStore._();
  final Map<String, dynamic> _dados = {};
  Timer? _debounceNome;

  Map<String, dynamic> get dados => _dados;

  Map<String, dynamic> get(int l, int g) =>
      (_dados['${l}_$g'] as Map?)?.cast<String, dynamic>() ??
      {'nome': '', 'dias': 0, 'pg': false};

  void setNome(int l, int g, String nome) {
    final k = '${l}_$g';
    final d = Map<String, dynamic>.from(get(l, g));
    d['nome'] = nome;
    _dados[k] = d;
    notifyListeners();
    _debounceNome?.cancel();
    _debounceNome = Timer(const Duration(milliseconds: 800), _salvar);
  }

  void toggleDia(int l, int g, int bit) {
    final k = '${l}_$g';
    final d = Map<String, dynamic>.from(get(l, g));
    d['dias'] = (d['dias'] as int) ^ bit;
    _dados[k] = d;
    notifyListeners();
    _salvar();
  }

  void togglePg(int l, int g) {
    final k = '${l}_$g';
    final d = Map<String, dynamic>.from(get(l, g));
    d['pg'] = !(d['pg'] as bool);
    _dados[k] = d;
    notifyListeners();
    _salvar();
  }

  void carregar(Map<String, dynamic> dados) {
    _dados.clear();
    dados.forEach((k, v) {
      if (v is Map) {
        _dados[k] = Map<String, dynamic>.from(v);
      }
    });
    notifyListeners();
  }

  Future<void> _salvar() async {
    await Cloud.salvar('eventos', {'dados': _dados});
  }
}

// ============== MAPAS STORE ==============
class MapasStore {
  static final Map<String, String> _fotos = {};

  static String? get(String territorio) => _fotos[territorio];

  static void set(String territorio, String? base64) {
    if (base64 == null || base64.isEmpty) {
      _fotos.remove(territorio);
    } else {
      _fotos[territorio] = base64;
    }
    Cloud.salvar('mapas', {territorio: base64 ?? ''});
  }

  static void carregar(Map<String, dynamic> dados) {
    _fotos.clear();
    dados.forEach((k, v) {
      if (v is String && v.isNotEmpty) _fotos[k] = v;
    });
  }
}

// ============== QUADRAS STORE ==============
class QuadrasStore {
  static final Map<String, List<List<int>>> _dados = {};

  static List<List<int>> get(String territorio) =>
      _dados[territorio] ??
      List.generate(10, (_) => List.generate(14, (_) => 0));

  static void set(String territorio, List<List<int>> estados) {
    _dados[territorio] = estados;
    _salvar(territorio);
  }

  static void carregar(Map<String, dynamic> dados) {
    _dados.clear();
    dados.forEach((terr, raw) {
      List<List<int>> matriz;
      if (raw is Map) {
        matriz = List.generate(10, (l) {
          final linhaRaw = raw['$l'];
          if (linhaRaw is List) {
            return List.generate(14, (c) {
              if (c < linhaRaw.length) {
                return int.tryParse(linhaRaw[c].toString()) ?? 0;
              }
              return 0;
            });
          }
          return List.generate(14, (_) => 0);
        });
      } else if (raw is List) {
        matriz = List.generate(10, (l) {
          if (l < raw.length && raw[l] is List) {
            final linha = raw[l] as List;
            return List.generate(14, (c) {
              if (c < linha.length) {
                return int.tryParse(linha[c].toString()) ?? 0;
              }
              return 0;
            });
          }
          return List.generate(14, (_) => 0);
        });
      } else {
        return;
      }
      _dados[terr] = matriz;
    });
  }

  static Future<void> _salvar(String territorio) async {
    final matriz = _dados[territorio];
    if (matriz == null) return;
    final out = <String, dynamic>{};
    for (int i = 0; i < matriz.length; i++) {
      out['$i'] = matriz[i];
    }
    await Cloud.salvar('quadras', {territorio: out});
  }
}



// ============== BOTÃO SALVAR ==============
class BotaoSalvar extends StatefulWidget {
  const BotaoSalvar({super.key});

  @override
  State<BotaoSalvar> createState() => _BotaoSalvarState();
}

class _BotaoSalvarState extends State<BotaoSalvar> {
  bool _salvando = false;

  Future<void> _dispararSalvamento() async {
    if (_salvando) return;
    setState(() => _salvando = true);

    try {
      final auth = AuthStore.instance;

      await Cloud.salvar('territorios', {
        'lista': TerritoriosStore.instance.lista.map((t) => t.toJson()).toList(),
      });

      if (auth.podeEditarImportante) {
        await Cloud.salvar('admins', {'senhas': auth.admins});
      }

      final nomesMap = <String, dynamic>{};
      for (int i = 0; i < DirigentesStore.nomes.length; i++) {
        nomesMap['$i'] = DirigentesStore.nomes[i];
      }
      await Cloud.salvar('dirigentes', {'nomes': nomesMap});

      await Cloud.salvar('servico_campo', {
        'locais': ServicoCampoStore.instance.locais,
      });

      await Cloud.salvar('eventos', {
        'dados': EventosStore.instance.dados,
      });

      AppState.instance.save();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.podeEditarImportante
              ? 'Dados sincronizados com sucesso!'
              : 'Alterações de Territórios salvas com sucesso!'),
          backgroundColor: const Color(0xFF2F855A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar na nuvem: $e'),
          backgroundColor: const Color(0xFFC53030),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _salvando
        ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: _dispararSalvamento,
            tooltip: 'Sincronizar com a Nuvem',
          );
  }
}

// ============== BADGE USUÁRIO ==============
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
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Visão Geral do Território',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: C.azul)),
        Icon(Icons.chevron_right, color: C.cinza),
      ]),
      const SizedBox(height: 12),
      Container(
        height: 150,
        decoration: BoxDecoration(color: C.bege, borderRadius: BorderRadius.circular(12)),
        child: Stack(children: [
          Center(child: Icon(Icons.map_outlined, size: 60, color: C.cinza.withValues(alpha: 0.6))),
          const Positioned(top: 25, left: 40,
              child: Icon(Icons.location_on, color: C.azul, size: 28)),
          const Positioned(top: 70, right: 80,
              child: Icon(Icons.location_on, color: C.amarelo, size: 24)),
          const Positioned(bottom: 20, right: 40,
              child: Icon(Icons.location_on, color: C.azul, size: 28)),
        ]),
      ),
    ]),
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
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalheTerritorioPage(numero: t.numero, nome: t.nome),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(children: [
                    const Icon(Icons.map, color: C.azul, size: 38),
                    const SizedBox(width: 16),
                    Expanded(child: Text('${t.numero} ${t.nome}',
                        style: const TextStyle(fontSize: 17,
                            fontWeight: FontWeight.bold, color: C.azul))),
                    IconButton(
                      icon: const Icon(Icons.edit, color: C.azul, size: 22),
                      onPressed: () => _editarNome(index),
                    ),
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

  // ✅ LIBERADO PARA TODOS
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
            fit: BoxFit.contain,   // ✅ Mostra a foto inteira
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
              // ✅ LIBERADO PARA TODOS
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
    _preencherControllers();
    _recarregarDoFirestore();
  }

  void _preencherControllers() {
    for (int coluna = 0; coluna < totalColunas; coluna++) {
      for (int i = 1; i < totalLinhas; i++) {
        _controllers[i][coluna].text = '';
      }
      final lista = DirigentesStore.nomes[coluna];
      for (int i = 0; i < lista.length && i < (totalLinhas - 1); i++) {
        _controllers[i + 1][coluna].text = lista[i];
      }
    }
  }

  Future<void> _recarregarDoFirestore() async {
    if (!Cloud.disponivel) return;
    try {
      final dir = await Cloud.ler('dirigentes');
      if (dir != null && dir['nomes'] != null) {
        final nomesMap = Map<String, dynamic>.from(dir['nomes'] as Map);
        final lista = List<List<String>>.generate(
          3,
          (i) => List<String>.from(nomesMap['$i'] ?? []),
        );
        DirigentesStore.carregar(lista);
        if (mounted) {
          _preencherControllers();
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Erro ao recarregar dirigentes: $e');
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

    // 🔒 Bloqueia acesso para não-admins
    if (!pode) {
      return Scaffold(
        backgroundColor: C.cinzaClaro,
        appBar: AppBar(
          backgroundColor: C.azul,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('DIRIGENTES',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, letterSpacing: 0.5)),
          centerTitle: true,
          actions: const [BadgeUsuario(), BotaoSalvar()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, size: 80, color: C.cinza),
                SizedBox(height: 16),
                Text('Acesso restrito',
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold, color: C.azul)),
                SizedBox(height: 8),
                Text('Apenas administradores podem abrir esta aba.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: C.cinza)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('DIRIGENTES',
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
                color: C.bege,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: C.azul, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seg-Sex → seg a sex | Sábado → sáb e dom | Domingo → só dom',
                    style: TextStyle(fontSize: 11,
                        color: C.azul, fontWeight: FontWeight.w600),
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
                            onChanged: (v) => _atualizarStore(linha, coluna, v),
                            style: const TextStyle(fontSize: 12,
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

    // 🔒 Bloqueia acesso para não-admins
    if (!pode) {
      return Scaffold(
        backgroundColor: C.cinzaClaro,
        appBar: AppBar(
          backgroundColor: C.azul,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('S.13',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, letterSpacing: 0.5)),
          centerTitle: true,
          actions: const [BadgeUsuario(), BotaoSalvar()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, size: 80, color: C.cinza),
                SizedBox(height: 16),
                Text('Acesso restrito',
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold, color: C.azul)),
                SizedBox(height: 8),
                Text('Apenas administradores podem abrir esta aba.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: C.cinza)),
              ],
            ),
          ),
        ),
      );
    }

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
            const SizedBox(height: 10),
            Row(children: [
              const Text('Ano de Serviço: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _anoServico,
                  style: const TextStyle(fontSize: 13, color: C.azul),
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

  late List<List<TextEditingController>> _nomes;
  bool _searchAtivo = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
    EventosStore.instance.addListener(_onChanged);
    _nomes = List.generate(
      totalLinhas,
      (_) => List.generate(totalGrupos, (_) => TextEditingController()),
    );
    _searchController.addListener(_onSearch);
    _preencherControllers();
    _recarregarDoFirestore();
  }

  void _preencherControllers() {
    for (int l = 0; l < totalLinhas; l++) {
      for (int g = 0; g < totalGrupos; g++) {
        _nomes[l][g].text = EventosStore.instance.get(l, g)['nome'] as String? ?? '';
      }
    }
  }

  Future<void> _recarregarDoFirestore() async {
    if (!Cloud.disponivel) return;
    try {
      final ev = await Cloud.ler('eventos');
      if (ev != null && ev['dados'] != null) {
        EventosStore.instance.carregar(Map<String, dynamic>.from(ev['dados']));
        if (mounted) {
          _preencherControllers();
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Erro ao recarregar eventos: $e');
    }
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    EventosStore.instance.removeListener(_onChanged);
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

  void _onChanged() {
    if (mounted) {
      for (int l = 0; l < totalLinhas; l++) {
        for (int g = 0; g < totalGrupos; g++) {
          final salvo = EventosStore.instance.get(l, g)['nome'] as String? ?? '';
          if (_nomes[l][g].text != salvo) {
            _nomes[l][g].text = salvo;
          }
        }
      }
      setState(() {});
    }
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
    EventosStore.instance.toggleDia(l, g, bit);
  }

  void _togglePg(int l, int g) {
    EventosStore.instance.togglePg(l, g);
  }

  @override
  Widget build(BuildContext context) {
    final pode = AuthStore.instance.podeEditarImportante;

    // 🔒 Bloqueia acesso para não-admins
    if (!pode) {
      return Scaffold(
        backgroundColor: C.cinzaClaro,
        appBar: AppBar(
          backgroundColor: C.azul,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('EVENTOS',
              style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, letterSpacing: 0.5)),
          centerTitle: true,
          actions: const [BadgeUsuario(), BotaoSalvar()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, size: 80, color: C.cinza),
                SizedBox(height: 16),
                Text('Acesso restrito',
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold, color: C.azul)),
                SizedBox(height: 8),
                Text('Apenas administradores podem abrir esta aba.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: C.cinza)),
              ],
            ),
          ),
        ),
      );
    }

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
            _aviso(),
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
                  ...List.generate(totalLinhas, (l) => _linha(l)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _aviso() {
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
        color: C.bege,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, color: C.azul, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Marque os dias (SEX/SÁB/DOM) e o pagamento (PG). Use a lupa.',
            style: TextStyle(fontSize: 11,
                color: C.azul, fontWeight: FontWeight.w600),
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

  Widget _linha(int l) {
    return Container(
      color: l.isEven ? Colors.white : const Color(0xFFF9FAFB),
      child: Row(
        children: List.generate(totalGrupos, (g) {
          return Row(children: [
            _celNum(l, g),
            _celNome(l, g),
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

  Widget _celNome(int l, int g) {
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
        onChanged: (v) => EventosStore.instance.setNome(l, g, v),
        style: TextStyle(fontSize: 11,
            color: C.azul,
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
    final dias = EventosStore.instance.get(l, g)['dias'] as int? ?? 0;
    final ativo = (dias & bit) != 0;
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
    final pago = EventosStore.instance.get(l, g)['pg'] as bool? ?? false;
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
  final String dataKey;
  final String mes;
  final String semana;
  final String horario;
  String local;
  String dirigente;
  _LinhaServico({
    required this.dataKey,
    required this.mes,
    required this.semana,
    required this.horario,
    this.local = '',
    this.dirigente = '',
  });
}
