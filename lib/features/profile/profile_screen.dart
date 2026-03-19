import 'package:flutter/material.dart';

import '../../services/demo_mode_service.dart';
import '../../services/supabase_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<bool>(
        future: DemoModeService.isEnabled(),
        builder: (context, demoSnap) {
          final demoEnabled = demoSnap.data ?? false;
          if (demoEnabled) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Você está no Modo Demo.\n\nPerfil simulado.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return FutureBuilder(
            future: service.fetchCurrentAppUser(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Falha ao carregar perfil: ${userSnap.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final user = userSnap.data;
              if (user == null) return const SizedBox.shrink();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName ?? '—',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text('E-mail: ${user.email}'),
                          const SizedBox(height: 6),
                          Text('SIAPE/SIGEPE: ${user.siape ?? '—'}'),
                          const SizedBox(height: 6),
                          Text('Perfil: ${user.role.name}'),
                          const SizedBox(height: 6),
                          Text(
                            'Organização: ${user.organizationName ?? user.organizationId ?? '—'}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

