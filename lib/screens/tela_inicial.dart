import 'package:flutter/material.dart';
import '../models/checklist_item.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final List<ChecklistItem> itens = [
    ChecklistItem(titulo: 'Sinalização adequada'),
    ChecklistItem(titulo: 'Extintores dentro da validade'),
    ChecklistItem(titulo: 'Saídas de emergência desobstruídas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist NR')),
      body: ListView.builder(
        itemCount: itens.length,
        itemBuilder: (context, index) {
          final item = itens[index];
          return CheckboxListTile(
            title: Text(item.titulo),
            value: item.concluido,
            onChanged: (value) {
              setState(() {
                item.concluido = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}
