import 'package:flutter/material.dart';
import 'tela_checklist.dart';
import 'tela_relatorios.dart';

class TelaSetores extends StatelessWidget {
  const TelaSetores({super.key});

  @override
  Widget build(BuildContext context) {
    final setores = [
      {"nome": "Enfermaria"},
      {"nome": "Almoxarifado"},
      {"nome": "Lavanderia"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Setor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver relatórios',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaRelatorios()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: setores.length,
        itemBuilder: (context, index) {
          final setor = setores[index];

          return ListTile(
            title: Text(setor["nome"]!),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TelaChecklist(nomeSetor: setor["nome"]!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
