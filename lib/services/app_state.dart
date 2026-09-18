import 'package:flutter/material.dart';

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
