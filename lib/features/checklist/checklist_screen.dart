import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';
import '../../services/demo_mode_service.dart';
import '../../services/demo_data_service.dart';
import '../../services/demo_inspection_storage_service.dart';
import '../../services/demo_pdf_service.dart';
import '../auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    final demoData = DemoDataService();
    final picker = ImagePicker();
    final demoStorage = DemoInspectionStorageService();
    final demoPdf = DemoPdfService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist NR-32 (Inspetor)'),
        actions: [
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
      body: FutureBuilder<bool>(
        future: DemoModeService.isEnabled(),
        builder: (context, snap) {
          final demoEnabled = snap.data ?? false;

          if (!demoEnabled) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Modo online.\n\nPróximo passo: carregar itens do checklist do Supabase, permitir marcar/observar/fotos e finalizar inspeção.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return FutureBuilder(
            future: demoData.loadChecklistItems(),
            builder: (context, itemsSnap) {
              if (itemsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (itemsSnap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Falha ao carregar checklist demo: ${itemsSnap.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final items = itemsSnap.data ?? const [];
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  if (i == items.length) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Finalizar inspeção (DEMO)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: () async {
                                final payload = <String, dynamic>{
                                  'generated_at': DateTime.now().toIso8601String(),
                                  'mode': 'demo',
                                  'items': items
                                      .map(
                                        (e) => {
                                          ...e.toMap(),
                                          'checked': true,
                                          'note': 'Registro em modo demo.',
                                          'photo_mock': e.isRequiredPhoto,
                                        },
                                      )
                                      .toList(),
                                };

                                final jsonPath =
                                    await demoStorage.saveInspectionJson(
                                  payload: payload,
                                );

                                final pdfPath =
                                    await demoPdf.generateInspectionPdf(
                                  organizationName: 'Organização (DEMO)',
                                  inspectorName: 'Inspetor (DEMO)',
                                  date: DateTime.now(),
                                  answeredItems:
                                      (payload['items'] as List<dynamic>)
                                          .cast<Map<String, dynamic>>(),
                                );

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Inspeção salva offline.\nJSON: ${Uri.file(jsonPath).pathSegments.last}\nPDF: ${Uri.file(pdfPath).pathSegments.last}',
                                    ),
                                  ),
                                );

                                final uri = Uri.file(pdfPath);
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: const Text('Salvar e gerar PDF (offline)'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final item = items[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nr32Section,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(item.itemDescription),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                item.isRequiredPhoto
                                    ? Icons.photo_camera
                                    : Icons.photo_camera_outlined,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.isRequiredPhoto
                                      ? 'Foto obrigatória (demo)'
                                      : 'Foto opcional (demo)',
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () async {
                                  // Obrigatório: câmera apenas (sem galeria)
                                  await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 85,
                                  );
                                },
                                child: const Text('Tirar foto'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

