import 'package:cloud_firestore/cloud_firestore.dart';

class Cloud {
  static final _db = FirebaseFirestore.instance;

  // ✅ id opcional — usa 'principal' se não passar
  static Future<Map<String, dynamic>?> ler(
    String colecao, [
    String id = 'principal',
  ]) async {
    final doc = await _db.collection(colecao).doc(id).get();
    return doc.data();
  }

  // ✅ dados é o 2º argumento, id é opcional
  static Future<void> salvar(
    String colecao,
    Map<String, dynamic> dados, [
    String id = 'principal',
  ]) async {
    await _db.collection(colecao).doc(id).set(
          dados,
          SetOptions(merge: true),
        );
  }
}
