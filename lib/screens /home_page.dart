import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/auth_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';
import 'admin_page.dart';
import 'eventos_page.dart';
import 's13_page.dart';
import 'servico_campo_page.dart';
import 'territorios_page.dart';
import 'dirigente_page.dart';

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

  void _abrir(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Início',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(),
                    const SizedBox(height: 12),
                    _infoSalvamento(),
                    const SizedBox(height: 12),
                    _infoPermissao(),
                    const SizedBox(height: 16),
                    _grid(),
                    const SizedBox(height: 20),
                    _secaoMapa(),
                    const SizedBox(height: 16),
                    _secaoNotas(),
                  ],
                ),
              ),
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: C.azul,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Territory Manager',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget _infoPermissao() {
    final pode = AuthStore.instance.podeEditarImportante;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: pode ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: pode ? const Color(0xFFA8D5A8) : C.amarelo.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(pode ? Icons.lock_open : Icons.lock_outline,
              color: pode ? C.verde : C.amarelo, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pode
                      ? 'Você tem permissão de administrador'
                      : 'Modo visitante (edição limitada)',
                  style: TextStyle(
                      fontSize: 12,
                      color: pode ? C.verde : C.amarelo,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  pode
                      ? 'Pode editar todas as partes do app'
                      : 'Só as grades DIRIGENTE e QUADRAS são editáveis',
                  style: const TextStyle(fontSize: 11, color: C.azul),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSalvamento() {
    final salvo = AppState.instance.lastSaved != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: salvo ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: salvo ? const Color(0xFFA8D5A8) : C.amarelo.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(salvo ? Icons.cloud_done : Icons.cloud_off,
              color: salvo ? C.verde : C.amarelo, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salvo ? 'Último salvamento' : 'Nenhum salvamento ainda',
                  style: TextStyle(
                      fontSize: 11,
                      color: salvo ? C.verde : C.amarelo,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  AppState.instance.lastSavedText,
                  style: const TextStyle(
                      fontSize: 13,
                      color: C.azul,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid() {
    final items = [
      {'icon': Icons.map_outlined, 'label': 'Territórios', 'acao': 'territorios'},
      {'icon': Icons.menu_book_outlined, 'label': 'Serviço de Campo', 'acao': 'servico'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Eventos', 'acao': 'eventos'},
      {'icon': Icons.person_pin_circle_outlined, 'label': 'Dirigente', 'acao': 'dirigente'},
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

  Widget _cardMenu({
    required IconData icon,
    required String label,
    required String acao,
  }) {
    return Material(
      color: C.bege,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          switch (acao) {
            case 'territorios':
              _abrir(const TerritoriosPage());
              break;
            case 'servico':
              _abrir(const ServicoCampoPage());
              break;
            case 'dirigente':
              _abrir(const DirigentePage());
              break;
            case 's13':
              _abrir(const S13Page());
              break;
            case 'eventos':
              _abrir(const EventosPage());
              break;
            case 'admin':
              _abrir(const AdminPage());
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: C.azul),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: C.azul, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoMapa() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tituloSecao('Visão Geral do Território'),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: C.bege,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.map_outlined,
                        size: 60, color: C.cinza.withOpacity(0.6)),
                  ),
                  const Positioned(
                      top: 25,
                      left: 40,
                      child: Icon(Icons.location_on, color: C.azul, size: 28)),
                  const Positioned(
                      top: 70,
                      right: 80,
                      child:
                          Icon(Icons.location_on, color: C.amarelo, size: 24)),
                  const Positioned(
                      bottom: 20,
                      right: 40,
                      child: Icon(Icons.location_on, color: C.azul, size: 28)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _secaoNotas() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tituloSecao('Notas recentes do serviço'),
            const SizedBox(height: 12),
            const Text('Nenhuma nota recente...',
                style: TextStyle(
                    color: C.cinza,
                    fontStyle: FontStyle.italic,
                    fontSize: 13)),
          ],
        ),
      );

  Widget _tituloSecao(String titulo) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: C.azul)),
          const Icon(Icons.chevron_right, color: C.cinza),
        ],
      );

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final ativo = i == _abaAtual;
          return InkWell(
            onTap: () => setState(() => _abaAtual = i),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[i]['icon'] as IconData,
                      color: ativo ? C.azul : C.cinza, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        color: ativo ? C.azul : C.cinza,
                        fontWeight:
                            ativo ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
