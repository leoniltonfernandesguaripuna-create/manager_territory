import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/cores.dart';

class BotaoSalvar extends StatelessWidget {
  const BotaoSalvar({super.key});

  void _salvar(BuildContext context) {
    AppState.instance.save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Salvo: ${AppState.instance.lastSavedText}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: C.verde,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Salvar',
      icon: const Icon(Icons.save, color: Colors.white),
      onPressed: () => _salvar(context),
    );
  }
}
