import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Cloud {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static bool _pronto = false;

  static Future<void> iniciar() async {
  try {
    await Firebase.initializeApp();
    _pronto = true;
    print('✅ FIREBASE OK');
  } catch (e) {
    _pronto = false;
    print('❌ ERRO FIREBASE: $e');
  }
}

  static bool get disponivel => _pronto;

  static Future<void> salvar(String doc, Map<String, dynamic> dados) async {
    if (!_pronto) return;
    try {
      await _db.collection('congregacao').doc(doc).set(dados);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> ler(String doc) async {
    if (!_pronto) return null;
    try {
      final d = await _db.collection('congregacao').doc(doc).get();
      return d.data();
    } catch (_) {
      return null;
    }
  }
}
