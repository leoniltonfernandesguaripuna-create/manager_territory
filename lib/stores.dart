import 'package:flutter/material.dart';

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

class AppState extends ChangeNotifier {
  
  });
}

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
    return true;
  }
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
