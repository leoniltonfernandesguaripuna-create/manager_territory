import 'package:flutter/material.dart';
import 'tema.dart';
import 'widgets.dart';
import 'tour.dart';

// =============================================================================
// TELA PRINCIPAL — TUTORIAL (texto rolável por seções)
// =============================================================================
class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('TUTORIAL',
            style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _botaoTour(context),
            const SizedBox(height: 16),
            _secao(
              icon: Icons.info_outline,
              titulo: 'O que é o app',
              cor: C.azul,
              conteudo: [
                'Este aplicativo ajuda a congregação a organizar o trabalho '
                'de campo, designar territórios, registrar dirigentes, acompanhar '
                'o serviço de campo mensal e gerenciar eventos.',
                'Todos os dados são salvos automaticamente na nuvem (Firebase) '
                'e ficam disponíveis no celular e no tablet ao mesmo tempo.',
              ],
            ),
            _secao(
              icon: Icons.map_outlined,
              titulo: 'Territórios (para todos)',
              cor: C.verde,
              conteudo: [
                '• Toque em "Territórios" no menu da Home.',
                '• Cada território tem um cadeado 🔒 quando está bloqueado.',
                '• Só abre o território se ele estiver LIBERADO pelo servo de território.',
                '• Se tentar tocar num bloqueado, aparece uma mensagem de aviso.',
                '• O território liberado tem fundo branco, ícone azul e botão ▶️.',
              ],
            ),
            _secao(
              icon: Icons.groups,
              titulo: 'Servo de Território',
              cor: C.azul,
              conteudo: [
                '• Acesso restrito: só servo cadastrado ou administrador entra.',
                '• Crie quantos grupos quiser (até 6 territórios por grupo).',
                '• Toque em ⊕ de um território livre pra designar a um grupo.',
                '• Toque no cadeado 🔒 pra LIBERAR um território pra trabalhar.',
                '⚠️ Só 1 território fica liberado por vez. Ao liberar um, os outros '
                'são bloqueados automaticamente.',
                '• Toque no ícone ⏱️ do topo pra ver a última data trabalhada de '
                'cada território (cores: verde até 45 dias, laranja até 90, vermelho acima).',
                '• Só o servo pode tocar no cadeado. Administrador vê, mas não mexe.',
              ],
            ),
            _secao(
              icon: Icons.menu_book_outlined,
              titulo: 'Serviço de Campo',
              cor: C.azul,
              conteudo: [
                '• Grade mensal com todos os dias do mês.',
                '• Cada linha tem: MÊS, SEMANA, LOCAL, HORÁRIO e DIRIGENTE.',
                '• A coluna LOCAL é editável e se repete em todos os meses.',
                '  - O local é salvo por dia da semana + horário. Ex: se você escrever '
                '"Salão do Reino" numa segunda, todas as segundas mostram esse valor.',
                '• Domingos normais mostram "Cada um do seu grupo" e DIRIGENTE = "SS do Grupo".',
                '• O último domingo mostra "Salão do Reino" e DIRIGENTE = irmão da coluna Domingo.',
                '• Quinta tem horário 17:30 (à tarde); os outros dias, 08:30.',
                '• Trocar de mês é só admin. Publicador só vê.',
              ],
            ),
            _secao(
              icon: Icons.calendar_today_outlined,
              titulo: 'Eventos',
              cor: C.azul,
              conteudo: [
                '• 4 grupos (colunas) com 20 nomes cada = 80 pessoas.',
                '• Cada pessoa pode ter SEX, SÁB e/ou DOM marcados — cada dia = 1 passagem.',
                '• Marque PG quando a pessoa já pagou.',
                '• No topo da tela aparecem 4 caixas:',
                '  - Passagens marcadas (todas)',
                '  - Valor por passagem (editável)',
                '  - Valor estipulado (a receber)',
                '  - Total recebido',
                '• Embaixo: Pessoas pagas, Passagens pagas e Restante (o que falta receber).',
                '• O valor por passagem é salvo na nuvem e vale pra todos os eventos.',
              ],
            ),
            _secao(
              icon: Icons.person_pin_circle_outlined,
              titulo: 'Dirigentes',
              cor: C.azul,
              conteudo: [
                '• 3 colunas: Seg-Sex, Sábado, Domingo.',
                '• Preencha os nomes dos irmãos que dirigem o campo.',
                '• Esses nomes aparecem automaticamente na aba Serviço de Campo.',
                '• Rotação: o app distribui os nomes em sequência pelos dias.',
                '• Só admin edita.',
              ],
            ),
            _secao(
              icon: Icons.assignment_outlined,
              titulo: 'S.13 — Registro de Designação',
              cor: C.azul,
              conteudo: [
                '• É a folha oficial de designações de território.',
                '• É alimentada automaticamente pelo card "Designação" dentro de cada território.',
                '• Mostra 4 blocos por território (nome do dirigente + datas).',
                '• O botão 🗑️ do topo limpa TODAS as designações (use só depois de imprimir o PDF).',
                '• Só admin acessa.',
              ],
            ),
            _secao(
              icon: Icons.admin_panel_settings_outlined,
              titulo: 'Administrador',
              cor: C.azul,
              conteudo: [
                '• 3 níveis de admin: Principal (senha 0000), A, B e C.',
                '• O Principal pode cadastrar e alterar as senhas de A, B e C.',
                '• Cadastro de Servos de Território:',
                '  - O admin cadastra o nome e a senha do servo.',
                '  - O servo depois entra com nome + senha na aba Servo de Território.',
                '• Admin (qualquer nível) pode editar tudo no app.',
                '• Publicador comum só edita Territórios.',
              ],
            ),
            _secao(
              icon: Icons.help_outline,
              titulo: 'Dúvidas frequentes',
              cor: C.amarelo,
              conteudo: [
                '❓ "Não consigo abrir o território."',
                '→ Ele está bloqueado. Peça ao servo de território pra liberar.',
                '',
                '❓ "Cadastrei um servo mas ele não consegue entrar."',
                '→ Confira se o nome e a senha batem exatamente (maiúsculas contam).',
                '',
                '❓ "Os dados sumiram."',
                '→ Verifique a internet. O app salva na nuvem — se ficar sem '
                'conexão, os dados só sincronizam quando voltar.',
                '',
                '❓ "O valor da passagem mudou em todos os meses."',
                '→ É intencional: o valor por passagem é global (vale pra todos os eventos).',
                '',
                '❓ "Posso ter mais de 1 território liberado?"',
                '→ Não. Sempre que libera um, o anterior é bloqueado automaticamente.',
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Território de Congregação • v1.0',
                style: TextStyle(fontSize: 11, color: C.cinza),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _botaoTour(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TourPage()),
        ),
        icon: const Icon(Icons.play_circle_outline, size: 24),
        label: const Text(
          '▶  Fazer o tour guiado',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: C.azul,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _secao({
    required IconData icon,
    required String titulo,
    required Color cor,
    required List<String> conteudo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: cor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          ...conteudo.map((linha) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  linha,
                  style: const TextStyle(
                    fontSize: 13,
                    color: C.azul,
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
