import 'package:flutter/material.dart';
import 'tema.dart';
import 'widgets.dart';

// =============================================================================
// TOUR GUIADO — passo a passo com slides
// =============================================================================
class TourPage extends StatefulWidget {
  const TourPage({super.key});
  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;

  final List<_Passo> _passos = const [
    _Passo(
      icone: Icons.waving_hand,
      cor: Color(0xFF1F3A5F),
      titulo: 'Bem-vindo!',
      descricao:
          'Vamos fazer um tour rápido pelo aplicativo. '
          'Em 8 passos você vai conhecer as principais funções.',
    ),
    _Passo(
      icone: Icons.home,
      cor: Color(0xFF1F3A5F),
      titulo: 'Tela inicial (Home)',
      descricao:
          '• Cabeçalho azul com o nome do app.\n'
          '• Caixa de "Nenhum salvamento ainda" — vira verde quando algo é salvo na nuvem.\n'
          '• Caixa de permissão — mostra se você é publicador ou administrador.\n'
          '• Grade com 6 cards de acesso rápido.',
    ),
    _Passo(
      icone: Icons.map_outlined,
      cor: Color(0xFF2F855A),
      titulo: 'Aba Territórios',
      descricao:
          'O coração do app.\n\n'
          '• Cada território tem um cadeado 🔒 quando está bloqueado.\n'
          '• Só abre se estiver LIBERADO pelo servo de território.\n'
          '• Dentro do território você preenche:\n'
          '   - Foto do mapa\n'
          '   - Designações (nome + datas)\n'
          '   - Grade de dirigentes\n'
          '   - Quadras trabalhadas\n'
          '   - Observações',
    ),
    _Passo(
      icone: Icons.groups,
      cor: Color(0xFF1F3A5F),
      titulo: 'Servo de Território',
      descricao:
          'Restrito a servo cadastrado ou admin.\n\n'
          '• Cria grupos ilimitados (máx. 6 territórios por grupo).\n'
          '• Designa territórios da lista geral pros grupos.\n'
          '• Toca no cadeado 🔒 pra LIBERAR 1 território pra trabalhar.\n'
          '• Só 1 liberado por vez — o resto bloqueia automaticamente.\n'
          '• Ícone ⏱️ mostra a última data trabalhada.',
    ),
    _Passo(
      icone: Icons.menu_book_outlined,
      cor: Color(0xFF1F3A5F),
      titulo: 'Serviço de Campo',
      descricao:
          'Grade mensal com todos os dias.\n\n'
          '• Coluna LOCAL é editável e se repete em todos os meses.\n'
          '• Domingos normais: "Cada um do seu grupo" + "SS do Grupo".\n'
          '• Último domingo: "Salão do Reino" + irmão da coluna Domingo.\n'
          '• Trocar de mês é só admin.',
    ),
    _Passo(
      icone: Icons.calendar_today_outlined,
      cor: Color(0xFF1F3A5F),
      titulo: 'Eventos',
      descricao:
          '4 grupos x 20 nomes = 80 pessoas.\n\n'
          '• Marque SEX, SÁB e/ou DOM — cada dia = 1 passagem.\n'
          '• Marque PG quando a pessoa pagar.\n'
          '• No topo: valor da passagem, valor a receber, total recebido.\n'
          '• Embaixo: pessoas pagas, passagens pagas, restante.',
    ),
    _Passo(
      icone: Icons.admin_panel_settings_outlined,
      cor: Color(0xFF1F3A5F),
      titulo: 'Administrador',
      descricao:
          'Login com senha (Principal = 0000).\n\n'
          '• Principal cadastra e altera senhas de A, B e C.\n'
          '• Cadastre Servos de Território: nome + senha.\n'
          '• O servo entra depois em Servo de Território com nome + senha.',
    ),
    _Passo(
      icone: Icons.help_outline,
      cor: Color(0xFFD97706),
      titulo: 'Dicas finais',
      descricao:
          '• Se um território não abrir, ele está bloqueado — peça ao servo.\n'
          '• Se algo não aparecer, verifique a internet.\n'
          '• Mais dúvidas? Volte ao Tutorial pela Home.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _proximo() {
    if (_paginaAtual < _passos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _anterior() {
    if (_paginaAtual > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _paginaAtual == _passos.length - 1;
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('TOUR GUIADO',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Pular',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progresso
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_paginaAtual + 1) / _passos.length,
                      minHeight: 6,
                      backgroundColor: C.borda,
                      valueColor: const AlwaysStoppedAnimation(C.verde),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_paginaAtual + 1} / ${_passos.length}',
                  style: const TextStyle(fontSize: 12, color: C.azul,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _paginaAtual = i),
                itemCount: _passos.length,
                itemBuilder: (_, i) => _slide(_passos[i]),
              ),
            ),
            // Botões
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(children: [
                if (_paginaAtual > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _anterior,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Anterior'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: C.azul,
                        side: BorderSide(color: C.azul.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (_paginaAtual > 0) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _proximo,
                    icon: Icon(ultimo ? Icons.check : Icons.chevron_right),
                    label: Text(ultimo ? 'Concluir' : 'Próximo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ultimo ? C.verde : C.azul,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slide(_Passo passo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: passo.cor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(passo.icone, size: 64, color: passo.cor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            passo.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: passo.cor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.borda),
            ),
            child: Text(
              passo.descricao,
              style: const TextStyle(
                fontSize: 14,
                color: C.azul,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Passo {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String descricao;

  const _Passo({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.descricao,
  });
}
