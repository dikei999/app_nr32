import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';
import '../../services/demo_mode_service.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Admin (Fiscal)'),
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
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.apartment),
              title: Text('Gerenciar Setores'),
              subtitle: Text('Criar/editar setores da organização.'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.checklist),
              title: Text('Gerenciar Checklists'),
              subtitle: Text('Criar/editar itens do checklist por setor.'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Convidar usuários'),
              subtitle: Text('Gerar convite ou código para entrar na organização.'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Relatórios'),
              subtitle: Text('Ver todos os relatórios da organização.'),
            ),
          ),
        ],
      ),
    );
  }
}

