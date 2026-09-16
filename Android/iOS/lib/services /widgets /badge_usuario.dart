import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import '../theme/cores.dart';

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
            avatar: Icon(
              logado ? Icons.verified_user : Icons.person_outline,
              color: Colors.white,
              size: 14,
            ),
            label: Text(
              AuthStore.instance.nomeUsuario,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: logado ? C.verde : C.cinza,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
}
