import 'package:flutter/material.dart';
import '../models/checklist_item.dart';
import 'tela_relatorios.dart';
import 'tela_checklist.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final List<String> setores = ['Enfermaria', 'Almoxarifado', 'Lavanderia'];

  final List<ChecklistItem> itens = [
    ChecklistItem(titulo: 'Sinalização adequada'),
    ChecklistItem(titulo: 'Extintores dentro da validade'),
    ChecklistItem(titulo: 'Saídas de emergência desobstruídas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: 'Relatórios',
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
          return ListTile(
            title: Text(setores[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TelaChecklist(nomeSetor: setores[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
