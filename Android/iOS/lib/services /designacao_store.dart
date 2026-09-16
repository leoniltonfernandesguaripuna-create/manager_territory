import 'package:flutter/material.dart';
import '../models/designacao.dart';

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
