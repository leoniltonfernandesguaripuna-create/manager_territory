import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Cloud {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static bool _pronto = false;

  static Future<void> iniciar() async {
    try {
      await Firebase.initializeApp();
      _pronto = true;
    } catch (_) {
      _pronto = false;
    }
  }

  static bool get disponivel => _pronto;

  static Future<void> salvar(
    String colecao,
    String id,
    Map<String, dynamic> dados,
  ) async {
    if (!_pronto) return;
    try {
      await _db.collection(colecao).doc(id).set(
            dados,
            SetOptions(merge: true),
          );
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> ler(String colecao, String id) async {
    if (!_pronto) return null;
    try {
      final doc = await _db.collection(colecao).doc(id).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ✅ ATALHOS: usam 'principal' como id fixo (chamados pelo main.dart)
  static Future<Map<String, dynamic>?> lerDoc(String colecao) =>
      ler(colecao, 'principal');

  static Future<void> salvarDoc(String colecao, Map<String, dynamic> dados) =>
      salvar(colecao, 'principal', dados);
}
