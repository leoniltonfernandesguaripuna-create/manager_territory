import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import '../theme/cores.dart';
import '../widgets/badge_usuario.dart';
import '../widgets/botao_salvar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuth);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuth);
    super.dispose();
  }

  void _onAuth() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.cinzaClaro,
      appBar: AppBar(
        backgroundColor: C.azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('ADMINISTRADOR',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5)),
        centerTitle: true,
        actions: const [BadgeUsuario(), BotaoSalvar()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AuthStore.instance.logado ? _painel() : _login(),
        ),
      ),
    );
  }

  Widget _login() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Icon(Icons.lock_outline, color: C.azul, size: 60),
                const SizedBox(height: 12),
                const Text('Acesso do Administrador',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: C.azul)),
                const SizedBox(height: 4),
                const Text(
                    'Somente administradores podem editar partes importantes do app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: C.cinza)),
                const SizedBox(height: 20),
                const _LoginForm(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _regras(),
        ],
      );

  Widget _regras() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: C.bege, borderRadius: BorderRadius.circular(12)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permissões',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: C.azul,
                    fontSize: 14)),
            SizedBox(height: 8),
            _ItemPermissao(
                icon: Icons.verified_user,
                texto: 'Admin Principal: cadastra A, B, C e edita tudo'),
            SizedBox(height: 6),
            _ItemPermissao(
                icon: Icons.admin_panel_settings,
                texto: 'Admins A, B, C: editam partes importantes'),
            SizedBox(height: 6),
            _ItemPermissao(
                icon: Icons.person_outline,
                texto: 'Visitante: só edita DIRIGENTE e QUADRAS'),
          ],
        ),
      );

  Widget _painel() {
    final u = AuthStore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: C.verde, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const Icon(Icons.verified_user, color: Colors.white, size: 60),
              const SizedBox(height: 10),
              Text('Bem-vindo, ${u.nomeUsuario}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                u.isPrincipal
                    ? 'Você pode cadastrar admins A, B e C'
                    : 'Você pode editar as partes importantes do app',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (u.isPrincipal) ...[
          _cadastroAdmins(),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              AuthStore.instance.logout();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Sessão encerrada'),
                  duration: Duration(seconds: 1)));
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.vermelho,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cadastroAdmins() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.group_add, color: C.azul, size: 22),
                SizedBox(width: 8),
                Text('Cadastro de Admins (A, B, C)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: C.azul,
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            for (final l in ['A', 'B', 'C']) _LinhaAdmin(letra: l),
          ],
        ),
      );
}

class _LinhaAdmin extends StatefulWidget {
  final String letra;
  const _LinhaAdmin({required this.letra});

  @override
  State<_LinhaAdmin> createState() => _LinhaAdminState();
}

class _LinhaAdminState extends State<_LinhaAdmin> {
  final _ctrl = TextEditingController();
  bool _oculto = true;

  @override
  void initState() {
    super.initState();
    _ctrl.text = AuthStore.instance.admins[widget.letra] ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: C.azul, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(widget.letra,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              obscureText: _oculto,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: C.azul),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Senha do admin ${widget.letra}',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                      _oculto ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: C.cinza),
                  onPressed: () => setState(() => _oculto = !_oculto),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.check_circle, color: C.verde),
            onPressed: () {
              final nova = _ctrl.text.trim();
              if (nova.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('A senha não pode estar vazia'),
                    backgroundColor: C.vermelho,
                    duration: Duration(seconds: 1)));
                return;
              }
              final ok =
                  AuthStore.instance.alterarSenhaAdmin(widget.letra, nova);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? 'Senha do admin ${widget.letra} atualizada'
                    : 'Não foi possível atualizar'),
                backgroundColor: ok ? C.verde : C.vermelho,
                duration: const Duration(seconds: 1),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  String _tipo = 'PRINCIPAL';
  final _senha = TextEditingController();
  bool _oculto = true;

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  void _entrar() {
    final s = _senha.text.trim();
    if (s.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Digite a senha'),
          backgroundColor: C.vermelho,
          duration: Duration(seconds: 1)));
      return;
    }
    final ok = AuthStore.instance.login(_tipo, s);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Senha incorreta'),
          backgroundColor: C.vermelho,
          duration: Duration(seconds: 2)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Entrar como:',
            style: TextStyle(fontSize: 12, color: C.cinza)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: C.borda),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipo,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: 'PRINCIPAL', child: Text('Admin Principal')),
                DropdownMenuItem(value: 'A', child: Text('Admin A')),
                DropdownMenuItem(value: 'B', child: Text('Admin B')),
                DropdownMenuItem(value: 'C', child: Text('Admin C')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _tipo = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _senha,
          obscureText: _oculto,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, color: C.azul),
          decoration: InputDecoration(
            isDense: true,
            labelText: 'Senha',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                  _oculto ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: C.cinza),
              onPressed: () => setState(() => _oculto = !_oculto),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _entrar,
            icon: const Icon(Icons.login),
            label: const Text('Entrar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemPermissao extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _ItemPermissao({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: C.azul, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto,
              style: const TextStyle(fontSize: 12, color: C.azul)),
        ),
      ],
    );
  }
}
