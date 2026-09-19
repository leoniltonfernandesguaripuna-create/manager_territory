import 'package:cloud_firestore/cloud_firestore.dart';

class Cloud {
  static final _db = FirebaseFirestore.instance;

  // API antiga (3 args em salvar, 2 em ler) — não mexe
  static Future<Map<String, dynamic>?> ler(String colecao, String id) async {
    final doc = await _db.collection(colecao).doc(id).get();
    return doc.data();
  }

  static Future<void> salvar(
    String colecao,
    String id,
    Map<String, dynamic> dados,
  ) async {
    await _db.collection(colecao).doc(id).set(
          dados,
          SetOptions(merge: true),
        );
  }

  // ✅ Atalhos usados por main.dart (documento único 'principal')
  static Future<Map<String, dynamic>?> lerDoc(String colecao) =>
      ler(colecao, 'principal');

  static Future<void> salvarDoc(
    String colecao,
    Map<String, dynamic> dados,
  ) =>
      salvar(colecao, 'principal', dados);
}
