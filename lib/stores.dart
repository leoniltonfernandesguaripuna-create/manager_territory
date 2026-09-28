import 'dart:async';
import 'package:flutter/material.dart';
import 'cloud.dart';

 class AuthStore extends ChangeNotifier {
  static final AuthStore instance = AuthStore._();
  AuthStore._();
  static const String senhaPrincipal = '0000';
  final Map<String, String> admins = {'A': '0000', 'B': '0000', 'C': '0000'};

  // ===== SERVOS DE TERRITÓRIO =====
  final Map<String, String> servos = {};
  String? _servoLogado;
  String? get servoLogado => _servoLogado;
  bool get isServo => _servoLogado != null;

  String? _usuario;
  String? get usuario => _usuario;
  bool get logado => _usuario != null;
  bool get isPrincipal => _usuario == 'PRINCIPAL';
  bool get isAdminABC => _usuario == 'A' || _usuario == 'B' || _usuario == 'C';
  bool get podeEditarImportante => isPrincipal || isAdminABC;

  bool get podeAcessarServoTerritorio =>
      isPrincipal || isAdminABC || isServo;

  String get nomeUsuario {
    if (_servoLogado != null) return 'Servo $_servoLogado';
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

  bool loginServo(String nome, String senha) {
    final n = nome.trim();
    if (servos.containsKey(n) && servos[n] == senha) {
      _servoLogado = n;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logoutServo() {
    _servoLogado = null;
    notifyListeners();
  }

  bool adicionarServo(String nome, String senha) {
    if (!podeEditarImportante) return false;
    final n = nome.trim();
    final s = senha.trim();
    if (n.isEmpty || s.isEmpty) return false;
    if (servos.containsKey(n)) return false;
    servos[n] = s;
    notifyListeners();
    _salvarServos();
    return true;
  }

  bool removerServo(String nome) {
    if (!podeEditarImportante) return false;
    if (!servos.containsKey(nome)) return false;
    servos.remove(nome);
    if (_servoLogado == nome) _servoLogado = null;
    notifyListeners();
    _salvarServos();
    return true;
  }

  bool alterarSenhaServo(String nome, String novaSenha) {
    if (!podeEditarImportante) return false;
    if (!servos.containsKey(nome)) return false;
    final s = novaSenha.trim();
    if (s.isEmpty) return false;
    servos[nome] = s;
    notifyListeners();
    _salvarServos();
    return true;
  }

  void carregarServos(Map<String, String> dados) {
    servos.clear();
    servos.addAll(dados);
    notifyListeners();
  }

  void _salvarServos() {
    Cloud.salvar('servos', {'lista': servos});
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
