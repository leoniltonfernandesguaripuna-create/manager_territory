import 'package:flutter/material.dart';
import 'tema.dart';
import 'stores.dart';
import 'widgets.dart';
import 'pages.dart';
// -----------------------------------------------------------------------------
// Diálogo de texto reutilizável
// -----------------------------------------------------------------------------
Future<String?> _pedirNome({
  required BuildContext context,
  required String titulo,
  required String label,
  required String acao,
  String valorInicial = '',
}) async {
  final ctrl = TextEditingController(text: valorInicial);
  final res = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: C.azul),
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: Text(acao, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  ctrl.dispose();
  if (res == null || res.isEmpty) return null;
  return res;
}

// =============================================================================
// TELA PRINCIPAL — lista de grupos
// =============================================================================
class ServoTerritorioPage extends StatefulWidget {
  const ServoTerritorioPage({super.key});
  @override
  State<ServoTerritorioPage> createState() => _ServoTerritorioPageState();
}

class _ServoTerritorioPageState extends State<ServoTerritorioPage> {
  @override
  void initState() {
    super.initState();
    GruposStore.instance.addListener(_onChanged);
    TerritoriosStore.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    GruposStore.instance.removeListener(_onChanged);
    TerritoriosStore.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _novoGrupo() async {
    final nome = await _pedirNome(
      context: context,
      titulo: 'Novo grupo',
      label: 'Nome do grupo',
      acao: 'Criar',
      valorInicial: 'Grupo ${GruposStore.instance.lista.length + 1}',
    );
    if (nome == null || !mounted) return;
    final ok = GruposStore.instance.adicionar(nome);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Já existe um grupo com esse nome.'),
        backgroundColor: C.vermelho,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final grupos = GruposStore.instance.lista;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('SERVO DE TERRITÓRIO',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: grupos.isEmpty
            ? _estadoVazio()
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: grupos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _cartaoGrupo(grupos[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoGrupo,
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo grupo'),
      ),
    );
  }

  Widget _estadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.groups_outlined, size: 80, color: C.cinza),
            SizedBox(height: 16),
            Text('Nenhum grupo criado ainda',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: C.azul)),
            SizedBox(height: 8),
            Text('Toque em "Novo grupo" para começar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: C.cinza)),
          ],
        ),
      ),
    );
  }

  Widget _cartaoGrupo(Grupo g) {
    final total = g.territorios.length;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GrupoDetalhePage(grupoId: g.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(children: [
            const CircleAvatar(
              backgroundColor: C.bege,
              foregroundColor: C.azul,
              radius: 24,
              child: Icon(Icons.groups),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.nome,
                      style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold, color: C.azul)),
                  const SizedBox(height: 4),
                  Text('$total/${Grupo.maxTerritorios} territórios',
                      style: const TextStyle(fontSize: 12, color: C.cinza)),
                  if (g.ativo != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.play_circle, color: C.verde, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('Trabalhando: ${g.ativo}',
                            style: const TextStyle(fontSize: 12,
                                color: C.verde, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            // Botão "+ território" direto no card
            if (!g.cheio)
              IconButton(
                tooltip: 'Adicionar território',
                icon: const Icon(Icons.add_circle, color: C.azul, size: 28),
                onPressed: () => _escolherTerritorio(context, g),
              ),
            const Icon(Icons.chevron_right, color: C.azul),
            const SizedBox(width: 4),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
// BOTTOM SHEET — escolher território com busca
// =============================================================================
Future<String?> _mostrarSeletorTerritorio(
  BuildContext context,
  Grupo grupo,
) async {
  final disponiveis = TerritoriosStore.instance.lista
      .where((t) => !grupo.territorios.contains(t.numero))
      .toList();

  if (disponiveis.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Todos os territórios já estão neste grupo.'),
      backgroundColor: C.vermelho,
    ));
    return null;
  }

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SeletorTerritorioSheet(
      disponiveis: disponiveis,
      onEscolher: (numero) => Navigator.pop(context, numero),
    ),
  );
}

class _SeletorTerritorioSheet extends StatefulWidget {
  const _SeletorTerritorioSheet({
    required this.disponiveis,
    required this.onEscolher,
  });

  final List<Territorio> disponiveis;
  final ValueChanged<String> onEscolher;

  @override
  State<_SeletorTerritorioSheet> createState() => _SeletorTerritorioSheetState();
}

class _SeletorTerritorioSheetState extends State<_SeletorTerritorioSheet> {
  final TextEditingController _busca = TextEditingController();
  late List<Territorio> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = widget.disponiveis;
    _busca.addListener(_filtrar);
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _filtrar() {
    final q = _busca.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtrados = widget.disponiveis;
      } else {
        _filtrados = widget.disponiveis.where((t) {
          return t.numero.toLowerCase().contains(q) ||
              t.nome.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: C.cinza,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Escolher território',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: C.azul)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _busca,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Buscar por número ou nome...',
                  prefixIcon: const Icon(Icons.search, color: C.azul),
                  suffixIcon: _busca.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _busca.clear();
                            _filtrar();
                          },
                        ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtrados.isEmpty
                  ? const Center(
                      child: Text('Nenhum território encontrado.',
                          style: TextStyle(color: C.cinza)),
                    )
                  : ListView.builder(
                      itemCount: _filtrados.length,
                      itemBuilder: (_, i) {
                        final t = _filtrados[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: C.bege,
                            foregroundColor: C.azul,
                            child: Text(
                              t.numero.replaceAll('T-', ''),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(t.nome,
                              style: const TextStyle(color: C.azul,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(t.numero),
                          onTap: () => widget.onEscolher(t.numero),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TELA DE DETALHE — designar territórios do grupo
// =============================================================================
class GrupoDetalhePage extends StatefulWidget {
  final String grupoId;
  const GrupoDetalhePage({super.key, required this.grupoId});
  @override
  State<GrupoDetalhePage> createState() => _GrupoDetalhePageState();
}

class _GrupoDetalhePageState extends State<GrupoDetalhePage> {
  @override
  void initState() {
    super.initState();
    GruposStore.instance.addListener(_onChanged);
    TerritoriosStore.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    GruposStore.instance.removeListener(_onChanged);
    TerritoriosStore.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final grupo = GruposStore.instance.porId(widget.grupoId);
    if (grupo == null) {
      return Scaffold(
        backgroundColor: C.cinzaClaro,
        appBar: AppBar(
          backgroundColor: C.azul,
          foregroundColor: Colors.white,
          title: const Text('Grupo'),
        ),
        body: const Center(child: Text('Grupo não encontrado.')),
      );
    }

    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(grupo.nome,
            style: const TextStyle(fontWeight: FontWeight.bold,
                fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Renomear grupo',
            icon: const Icon(Icons.edit),
            onPressed: () => _renomear(grupo),
          ),
          IconButton(
            tooltip: 'Excluir grupo',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _excluir(grupo),
          ),
          const BotaoSalvar(),
        ],
      ),
      body: SafeArea(
        child: grupo.vazio
            ? _grupoVazio()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: grupo.territorios.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _linhaTerritorio(grupo, grupo.territorios[i]),
              ),
      ),
      floatingActionButton: grupo.cheio
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _escolherTerritorio(context, grupo),
              backgroundColor: C.azul,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Designar território'),
            ),
    );
  }

  Widget _grupoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_outlined, size: 80, color: C.cinza),
            SizedBox(height: 16),
            Text('Nenhum território designado',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: C.azul)),
            SizedBox(height: 8),
            Text('Toque em "Designar território" para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: C.cinza)),
          ],
        ),
      ),
    );
  }

  Widget _linhaTerritorio(Grupo grupo, String numero) {
    final terr = TerritoriosStore.instance.lista.firstWhere(
      (t) => t.numero == numero,
      orElse: () => Territorio(numero: numero, nome: '(removido)'),
    );
    final ativo = grupo.ativo == numero;

    return Material(
      color: ativo ? const Color(0xFFE6F4EA) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => GruposStore.instance.definirAtivo(grupo.id, numero),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: ativo ? C.verde : C.bege,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(numero.replaceAll('T-', ''),
                  style: TextStyle(
                      color: ativo ? Colors.white : C.azul,
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$numero ${terr.nome}',
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.bold, color: C.azul)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      ativo ? 'Em andamento'
                            : 'Toque para marcar como ativo',
                      style: TextStyle(fontSize: 11,
                          color: ativo ? C.verde : C.cinza,
                          fontWeight: ativo ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent),
              tooltip: 'Remover do grupo',
              onPressed: () => _confirmarRemover(grupo, numero),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _renomear(Grupo g) async {
    final nome = await _pedirNome(
      context: context,
      titulo: 'Renomear grupo',
      label: 'Nome do grupo',
      acao: 'Salvar',
      valorInicial: g.nome,
    );
    if (nome == null) return;
    GruposStore.instance.renomear(g.id, nome);
  }

  Future<void> _excluir(Grupo g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir grupo'),
        content: Text('Tem certeza que deseja excluir "${g.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.vermelho),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      GruposStore.instance.excluir(g.id);
      Navigator.pop(context);
    }
  }

  Future<void> _confirmarRemover(Grupo g, String numero) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover território'),
        content: Text('Remover $numero do grupo "${g.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.vermelho),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      GruposStore.instance.removerTerritorio(g.id, numero);
    }
  }
}

// =============================================================================
// Função compartilhada de "escolher território"
// =============================================================================

/// Abre o seletor, e se o usuário escolher, adiciona ao grupo.
/// Retorna `true` se algo foi adicionado.
Future<bool> _escolherTerritorio(BuildContext context, Grupo grupo) async {
  final escolhido = await _mostrarSeletorTerritorio(context, grupo);
  if (escolhido == null || !context.mounted) return false;

  final erro = GruposStore.instance.adicionarTerritorio(grupo.id, escolhido);
  if (erro != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(erro), backgroundColor: C.vermelho,
    ));
    return false;
  }
  return true;
}
