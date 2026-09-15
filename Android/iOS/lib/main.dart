import 'package:flutter/material.dart';

void main() {
  runApp(const TerritorioManagerApp());
}

class TerritorioManagerApp extends StatelessWidget {
  const TerritorioManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Território Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F4F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D3D68),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int diaSelecionado = 14;

  final List<int> dias = [12, 13, 14, 15, 16, 17, 18, 19];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D3D68),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'MAPA DO TERRITÓRIO',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _calendario(),
              const SizedBox(height: 24),
              const Text(
                'Território de Congregação',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFF1D3D68),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  MenuCard(
                    icone: Icons.map_outlined,
                    titulo: 'Territórios',
                    onTap: () => _mostrarAviso('Territórios'),
                  ),
                  MenuCard(
                    icone: Icons.calendar_month_outlined,
                    titulo: 'Serviço de
Campo',
                    onTap: () => _mostrarAviso('Serviço de Campo'),
                  ),
                  MenuCard(
                    icone: Icons.event_available_outlined,
                    titulo: 'Eventos',
                    onTap: () => _mostrarAviso('Eventos'),
                  ),
                  MenuCard(
                    icone: Icons.visibility_outlined,
                    titulo: 'Dirigente',
                    onTap: () => _mostrarAviso('Dirigente'),
                  ),
                  MenuCard(
                    icone: Icons.edit_outlined,
                    titulo: 'S-13',
                    onTap: () => _mostrarAviso('S-13'),
                  ),
                  MenuCard(
                    icone: Icons.admin_panel_settings_outlined,
                    titulo: 'Administrador',
                    onTap: () => _mostrarAviso('Administrador'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendario() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF9D2632),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Setembro 2026 (Ativo: 13/09/2026)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dias.map((dia) {
              final selecionado = dia == diaSelecionado;

              return InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  setState(() {
                    diaSelecionado = dia;
                  });
                },
                child: Container(
                  width: 30,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selecionado
                        ? const Color(0xFF1D3D68)
                        : Colors.white,
                    border: Border.all(
                      color: const Color(0xFFCCD3DA),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$dia',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selecionado
                          ? Colors.white
                          : const Color(0xFF37474F),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _mostrarAviso(String nomePagina) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tela de $nomePagina será criada em seguida.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                size: 29,
                color: const Color(0xFF68798B),
              ),
              const SizedBox(height: 9),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF22313F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
