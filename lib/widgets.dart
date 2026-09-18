import 'package:flutter/material.dart';
import 'cores.dart';
import 'stores.dart';

class BotaoSalvar extends StatelessWidget {
  const BotaoSalvar({super.key});
  void _salvar(BuildContext context) {
    AppState.instance.save();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Salvo: ${AppState.instance.lastSavedText}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ]),
      backgroundColor: C.verde,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
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

class BadgeUsuario extends StatelessWidget {
  const BadgeUsuario({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthStore.instance,
      builder: (context, _) {
        final logado = AuthStore.instance.logado;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Chip(
            avatar: Icon(logado ? Icons.verified_user : Icons.person_outline,
                color: Colors.white, size: 14),
            label: Text(AuthStore.instance.nomeUsuario,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            backgroundColor: logado ? C.verde : C.cinza,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}
