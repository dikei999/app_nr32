import 'package:flutter/material.dart';

import '../../services/demo_mode_service.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';
import '../checklist/checklist_screen.dart';
import '../profile/profile_screen.dart';

class InspectorDashboardScreen extends StatelessWidget {
  const InspectorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Inspetor'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PerfilScreen()),
              );
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              final demoEnabled = await DemoModeService.isEnabled();
              if (demoEnabled) {
                await DemoModeService.disable();
              } else {
                await service.signOut();
              }
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Nova inspeção'),
              subtitle: const Text('Inicie um checklist e registre evidências.'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChecklistScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Próximo passo: listar checklists pendentes e histórico de inspeções do usuário.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

