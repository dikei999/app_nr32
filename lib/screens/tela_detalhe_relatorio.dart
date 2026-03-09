import 'dart:io';
import 'package:flutter/material.dart';

class TelaDetalheRelatorio extends StatelessWidget {
  final Map relatorio;

  const TelaDetalheRelatorio({super.key, required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final itens = relatorio["itens"] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Relatório - ${relatorio["setor"]}')),
      body: ListView.builder(
        itemCount: itens.length,
        itemBuilder: (context, index) {
          final item = itens[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["titulo"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text('Status: ${item["status"] ?? "NA"}'),

                  if ((item["observacao"] ?? "").toString().isNotEmpty)
                    Text('Obs: ${item["observacao"]}'),

                  const SizedBox(height: 6),

                  if (item["foto"] != null &&
                      item["foto"].toString().isNotEmpty)
                    Image.file(File(item["foto"]), height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
