import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'cloud.dart';
import 'tema.dart';
import 'stores.dart';
import 'widgets.dart';

// ============== HOME ==============
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _abaAtual = 0;
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onChanged);
    AuthStore.instance.addListener(_onChanged);
  }
  @override
  void dispose() {
    AppState.instance.removeListener(_onChanged);
    AuthStore.instance.removeListener(_onChanged);
    super.dispose();
  }
  void _onChanged() {
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Início',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _header(),
              const SizedBox(height: 12),
              _infoSalvamento(),
              const SizedBox(height: 12),
              _infoPermissao(),
              const SizedBox(height: 16),
              _grid(),
              const SizedBox(height: 20),
              _cardMapa(),
              const SizedBox(height: 16),
              _cardNotas(),
            ]),
          )),
          _bottomNav(),
        ]),
      ),
    );
  }
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(color: C.azul, borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Text('Território de Congregação',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
  Widget _infoSalvamento() {
    final s = AppState.instance.lastSaved != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: s ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: s ? const Color(0xFFA8D5A8) : C.amarelo),
      ),
      child: Row(children: [
        Icon(s ? Icons.cloud_done : Icons.cloud_off, color: s ? C.verde : C.amarelo, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s ? 'Último salvamento' : 'Nenhum salvamento ainda',
              style: TextStyle(fontSize: 11, color: s ? C.verde : C.amarelo, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(AppState.instance.lastSavedText,
              style: const TextStyle(fontSize: 13, color: C.azul, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
  Widget _infoPermissao() {
    final p = AuthStore.instance.podeEditarImportante;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p ? const Color(0xFFA8D5A8) : C.amarelo),
      ),
      child: Row(children: [
        Icon(p ? Icons.lock_open : Icons.lock_outline, color: p ? C.verde : C.amarelo, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p ? 'Modo administrador' : 'Modo publicador',
              style: TextStyle(fontSize: 12, color: p ? C.verde : C.amarelo, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(p ? 'Pode editar todas as partes do app' : 'Só edita a aba Territórios',
              style: const TextStyle(fontSize: 11, color: C.azul)),
        ])),
      ]),
    );
  }
  Widget _grid() {
    final items = [
      {'icon': Icons.map_outlined, 'label': 'Territórios', 'acao': 'territorios'},
      {'icon': Icons.menu_book_outlined, 'label': 'Serviço de Campo', 'acao': 'servico'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Eventos', 'acao': 'eventos'},
      {'icon': Icons.person_pin_circle_outlined, 'label': 'Dirigentes', 'acao': 'dirigente'},
      {'icon': Icons.assignment_outlined, 'label': 'S.13', 'acao': 's13'},
      {'icon': Icons.admin_panel_settings_outlined, 'label': 'Administrador', 'acao': 'admin'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, i) => _cardMenu(
        icon: items[i]['icon'] as IconData,
        label: items[i]['label'] as String,
        acao: items[i]['acao'] as String,
      ),
    );
  }
  Widget _cardMenu({required IconData icon, required String label, required String acao}) {
    return Container(
      decoration: BoxDecoration(
        color: C.bege,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.azul.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: C.azul.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (acao == 'eventos' ||
                acao == 's13' ||
                acao == 'dirigente') {
              if (!AuthStore.instance.podeEditarImportante) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Apenas administradores podem abrir esta aba.'),
                  backgroundColor: C.vermelho,
                  duration: Duration(seconds: 2),
                ));
                return;
              }
            }

            if (acao == 'territorios') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TerritoriosPage()));
            } else if (acao == 'servico') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicoCampoPage()));
            } else if (acao == 'dirigente') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DirigentePage()));
            } else if (acao == 's13') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const S13Page()));
            } else if (acao == 'eventos') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EventosPage()));
            } else if (acao == 'admin') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 30, color: C.azul),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: C.azul, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _cardMapa() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Visão Geral do Território',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: C.azul)),
          Icon(Icons.chevron_right, color: C.cinza),
        ]),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(color: C.bege, borderRadius: BorderRadius.circular(12)),
          child: Stack(children: [
            Center(child: Icon(Icons.map_outlined, size: 60, color: C.cinza.withValues(alpha: 0.6))),
            const Positioned(top: 25, left: 40,
                child: Icon(Icons.location_on, color: C.azul, size: 28)),
            const Positioned(top: 70, right: 80,
                child: Icon(Icons.location_on, color: C.amarelo, size: 24)),
            const Positioned(bottom: 20, right: 40,
                child: Icon(Icons.location_on, color: C.azul, size: 28)),
          ]),
        ),
      ]),
    );
  }
  Widget _cardNotas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Notas recentes do serviço',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: C.azul)),
        SizedBox(height: 12),
        Text('Nenhuma nota recente...',
            style: TextStyle(color: C.cinza, fontStyle: FontStyle.italic, fontSize: 13)),
      ]),
    );
  }
  Widget _bottomNav() {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.person_outline, 'label': 'Meu Perfil'},
      {'icon': Icons.mail_outline, 'label': 'Mensagens'},
      {'icon': Icons.settings_outlined, 'label': 'Configurações'},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final ativo = i == _abaAtual;
          return InkWell(
            onTap: () => setState(() => _abaAtual = i),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i]['icon'] as IconData,
                    color: ativo ? C.azul : C.cinza, size: 24),
                const SizedBox(height: 4),
                Text(items[i]['label'] as String,
                    style: TextStyle(fontSize: 10, color: ativo ? C.azul : C.cinza,
                        fontWeight: ativo ? FontWeight.bold : FontWeight.normal)),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ============== TERRITÓRIOS ==============
class TerritoriosPage extends StatefulWidget {
  const TerritoriosPage({super.key});
  @override
  State<TerritoriosPage> createState() => _TerritoriosPageState();
}

class _TerritoriosPageState extends State<TerritoriosPage> {
  @override
  void initState() {
    super.initState();
    TerritoriosStore.instance.addListener(_onChanged);
    AuthStore.instance.addListener(_onChanged);
  }
  @override
  void dispose() {
    TerritoriosStore.instance.removeListener(_onChanged);
    AuthStore.instance.removeListener(_onChanged);
    super.dispose();
  }
  void _onChanged() {
    if (mounted) setState(() {});
  }
  void _editarNome(int index) {
    final t = TerritoriosStore.instance.lista[index];
    final ctrl = TextEditingController(text: t.nome);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Renomear ${t.numero}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome do território',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.azul),
            onPressed: () {
              final novo = ctrl.text.trim();
              if (novo.isNotEmpty) TerritoriosStore.instance.renomear(index, novo);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final lista = TerritoriosStore.instance.lista;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('TERRITÓRIOS DA CONGREGAÇÃO',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final t = lista[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalheTerritorioPage(numero: t.numero, nome: t.nome),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(children: [
                    const Icon(Icons.map, color: C.azul, size: 38),
                    const SizedBox(width: 16),
                    Expanded(child: Text('${t.numero} ${t.nome}',
                        style: const TextStyle(fontSize: 17,
                            fontWeight: FontWeight.bold, color: C.azul))),
                    IconButton(
                      icon: const Icon(Icons.edit, color: C.azul, size: 22),
                      onPressed: () => _editarNome(index),
                    ),
                    const Icon(Icons.play_arrow, color: C.amarelo, size: 30),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
