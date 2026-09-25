import 'dart:async';
import 'package:flutter/material.dart';
import 'cloud.dart';

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

// ============== DIRIGENTE TERRITÓRIO STORE ==============
class DirigenteTerritorioStore {
  static final Map<String, Map<String, String>> _dados = {};

  static String valor(String territorio, int linha, int coluna) {
    final map = _dados[territorio];
    if (map == null) return '';
    return map['${linha}_$coluna'] ?? '';
  }

  static void set(String territorio, int linha, int coluna, String valor) {
    _dados.putIfAbsent(territorio, () => {});
    _dados[territorio]!['${linha}_$coluna'] = valor;
    _salvar(territorio);
  }

  static void carregar(Map<String, dynamic> dados) {
    _dados.clear();
    dados.forEach((terr, map) {
      if (map is Map) {
        final m = <String, String>{};
        map.forEach((k, v) => m[k] = v.toString());
        _dados[terr] = m;
      }
    });
  }

  static Future<void> _salvar(String territorio) async {
    await Cloud.salvar('dirigentes_territorio', {
      territorio: _dados[territorio],
    });
  }
}
