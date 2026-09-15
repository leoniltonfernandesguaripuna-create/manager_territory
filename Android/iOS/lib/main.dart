import 'package:flutter/material.dart';

void main() {
  runApp(const TerritoryManagerApp());
}

class TerritoryManagerApp extends StatelessWidget {
  const TerritoryManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'territory_manager',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFA6BAC8), // Fundo azul acinzentado do print
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedDay = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF112D4E),
        title: const Text(
          'MAPA DO TERRITÓRIO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card do Calendário
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Color(0xFF8B263E), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Setembro 2026 (Ativo: 13/09/2026)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(8, (index) {
                        int day = 12 + index;
                        bool isSelected = day == selectedDay;
                        return GestureDetector(
                          onTap: () => setState(() => selectedDay = day),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Território de Congregação',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF112D4E),
                ),
              ),
              const SizedBox(height: 16),
              
              // Grid de Funcionalidades
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  MenuCard(icon: Icons.map_outlined, label: 'Territórios'),
                  MenuCard(icon: Icons.calendar_today_outlined, label: 'Serviço de Campo'),
                  MenuCard(icon: Icons.event_available_outlined, label: 'Eventos'),
                  MenuCard(icon: Icons.visibility_outlined, label: 'Dirigente'),
                  MenuCard(icon: Icons.edit_outlined, label: 'S-13'),
                  MenuCard(icon: Icons.admin_panel_settings_outlined, label: 'Administrador'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: const Color(0xFF4A5568)),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}
