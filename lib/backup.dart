import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'cloud.dart';
import 'tema.dart';

// Coleções que serão salvas no backup.
const List<String> _colecoes = [
  'territorios',
  'designacoes',
  'observacoes',
  'dirigentes',
  'admins',
  'servico_campo',
  'eventos',
  'mapas',
  'quadras',
  'dirigentes_territorio',
  'servos',
  'grupos',
];

// =============================================================================
// EXPORTAR BACKUP (salvar arquivo .json)
// =============================================================================
Future<void> exportarBackup(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    // Mostra carregando
    messenger.showSnackBar(const SnackBar(
      content: Text('Gerando backup...'),
      duration: Duration(seconds: 1),
    ));

    // Lê todas as coleções
    final dados = <String, dynamic>{};
    for (final col in _colecoes) {
      final doc = await Cloud.ler(col);
      if (doc != null) dados[col] = doc;
    }

    // Adiciona metadados
    dados['_meta'] = {
      'data': DateTime.now().toIso8601String(),
      'versao': 1,
      'app': 'Território de Congregação',
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(dados);

    // Salva no diretório temporário
    final dir = await getTemporaryDirectory();
    final dt = DateTime.now();
    final nome =
        'backup_territorio_${dt.year}${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}_'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}.json';
    final file = File('${dir.path}/$nome');
    await file.writeAsString(jsonStr);

    // Compartilha (Google Drive, WhatsApp, E-mail, etc.)
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Backup do app Território de Congregação',
    );

    if (context.mounted) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Backup gerado com sucesso!'),
        backgroundColor: C.verde,
      ));
    }
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(SnackBar(
        content: Text('Erro ao gerar backup: $e'),
        backgroundColor: C.vermelho,
      ));
    }
  }
}

// =============================================================================
// IMPORTAR BACKUP (escolher arquivo .json e restaurar)
// =============================================================================
Future<void> importarBackup(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    // Escolhe o arquivo
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null) return;

    final conteudo = await File(path).readAsString();
    final dados = jsonDecode(conteudo) as Map<String, dynamic>;

    // Pega a data do backup pra mostrar
    String dataBackup = 'data desconhecida';
    if (dados['_meta'] is Map && dados['_meta']['data'] != null) {
      try {
        final dt = DateTime.parse(dados['_meta']['data'].toString());
        dataBackup =
            '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/${dt.year} às '
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    if (!context.mounted) return;

    // Confirmação
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar backup?'),
        content: Text(
          'Backup de: $dataBackup\n\n'
          '⚠️ ATENÇÃO: Isso vai SUBSTITUIR todos os dados atuais '
          'pelos dados deste arquivo.\n\n'
          'Use apenas se tiver certeza.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.vermelho),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restaurar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // Restaura cada coleção
    for (final col in _colecoes) {
      if (dados[col] != null && dados[col] is Map) {
        await Cloud.salvar(col, Map<String, dynamic>.from(dados[col]));
      }
    }

    if (context.mounted) {
      messenger.showSnackBar(const SnackBar(
        content: Text(
            'Backup restaurado! Feche e reabra o app para atualizar as telas.'),
        backgroundColor: C.verde,
        duration: Duration(seconds: 5),
      ));
    }
  } catch (e) {
    if (context.mounted) {
      messenger.showSnackBar(SnackBar(
        content: Text('Erro ao restaurar: $e'),
        backgroundColor: C.vermelho,
      ));
    }
  }
}
