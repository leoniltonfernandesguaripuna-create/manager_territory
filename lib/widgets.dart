import 'package:flutter/material.dart';
import 'cloud.dart';
import 'tema.dart';
import 'stores.dart';

// ============== BOTÃO SALVAR ==============
class BotaoSalvar extends StatefulWidget {
  const BotaoSalvar({super.key});

  @override
  State<BotaoSalvar> createState() => _BotaoSalvarState();
}

class _BotaoSalvarState extends State<BotaoSalvar> {
  bool _salvando = false;

  Future<void> _dispararSalvamento() async {
    if (_salvando) return;
    setState(() => _salvando = true);

    try {
      final auth = AuthStore.instance;

      await Cloud.salvar('territorios', {
        'lista': TerritoriosStore.instance.lista.map((t) => t.toJson()).toList(),
      });

      if (auth.podeEditarImportante) {
        await Cloud.salvar('admins', {'senhas': auth.admins});
      }

      final nomesMap = <String, dynamic>{};
      for (int i = 0; i < DirigentesStore.nomes.length; i++) {
        nomesMap['$i'] = DirigentesStore.nomes[i];
      }
      await Cloud.salvar('dirigentes', {'nomes': nomesMap});

      await Cloud.salvar('servico_campo', {
        'locais': ServicoCampoStore.instance.locais,
      });

      await Cloud.salvar('eventos', {
        'dados': EventosStore.instance.dados,
      });

      AppState.instance.save();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.podeEditarImportante
              ? 'Dados sincronizados com sucesso!'
              : 'Alterações de Territórios salvas com sucesso!'),
          backgroundColor: const Color(0xFF2F855A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar na nuvem: $e'),
          backgroundColor: const Color(0xFFC53030),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _salvando
        ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: _dispararSalvamento,
            tooltip: 'Sincronizar com a Nuvem',
          );
  }
}

// ============== BADGE USUÁRIO ==============
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
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
