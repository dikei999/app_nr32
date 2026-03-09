import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_storage_service.dart';

class TelaChecklist extends StatefulWidget {
  final String nomeSetor;

  const TelaChecklist({super.key, required this.nomeSetor});

  @override
  State<TelaChecklist> createState() => _TelaChecklistState();
}

class _TelaChecklistState extends State<TelaChecklist> {
  List itensChecklist = [];
  final ImagePicker _picker = ImagePicker();

  String get chave => 'checklist_${widget.nomeSetor}';

  @override
  void initState() {
    super.initState();
    _carregarChecklist();
  }

  void _carregarChecklist() {
    final itensSalvos = LocalStorageService.getChecklistItens(chave);

    if (itensSalvos.isEmpty) {
      itensChecklist = [
        {
          "titulo": "Tanque identificado corretamente?",
          "status": "NA",
          "observacao": "",
          "foto": null,
        },
        {
          "titulo": "Há sinalização de segurança?",
          "status": "NA",
          "observacao": "",
          "foto": null,
        },
        {
          "titulo": "Existe vazamento aparente?",
          "status": "NA",
          "observacao": "",
          "foto": null,
        },
      ];

      LocalStorageService.salvarChecklistItens(chave, itensChecklist);
    } else {
      itensChecklist = List.from(itensSalvos);
    }

    setState(() {});
  }

  // ✅ NOVO — FINALIZAR CHECKLIST
  Future<void> _finalizarChecklist() async {
    final relatorio = {
      "setor": widget.nomeSetor,
      "data": DateTime.now().toIso8601String(),
      "itens": itensChecklist,
    };

    final relatorios = LocalStorageService.getRelatorios();
    relatorios.add(relatorio);

    await LocalStorageService.salvarRelatorios(relatorios);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Relatório salvo offline')));
  }

  Future<void> _tirarFoto(int index) async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.camera);

    if (imagem != null) {
      setState(() {
        itensChecklist[index]["foto"] = imagem.path;
      });

      LocalStorageService.salvarChecklistItens(chave, itensChecklist);
    }
  }

  void _editarObservacao(int index, String texto) {
    itensChecklist[index]["observacao"] = texto;
    LocalStorageService.salvarChecklistItens(chave, itensChecklist);
  }

  void _mudarStatus(int index, String status) {
    setState(() {
      itensChecklist[index]["status"] = status;
    });

    LocalStorageService.salvarChecklistItens(chave, itensChecklist);
  }

  Widget _botaoStatus(int index, String valor, String label) {
    final selecionado = itensChecklist[index]["status"] == valor;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selecionado ? Colors.blue : Colors.grey.shade400,
          ),
          onPressed: () => _mudarStatus(index, valor),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checklist - ${widget.nomeSetor}')),

      body: ListView.builder(
        itemCount: itensChecklist.length,
        itemBuilder: (context, index) {
          final item = itensChecklist[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["titulo"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ===== BOTÕES C / NC / NA =====
                  Row(
                    children: [
                      _botaoStatus(index, "C", "C"),
                      _botaoStatus(index, "NC", "NC"),
                      _botaoStatus(index, "NA", "NA"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ===== FOTO =====
                  if (item["foto"] != null)
                    Image.file(File(item["foto"]), height: 120),

                  ElevatedButton.icon(
                    onPressed: () => _tirarFoto(index),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tirar foto"),
                  ),

                  const SizedBox(height: 10),

                  // ===== OBSERVAÇÃO =====
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Observações",
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: item["observacao"]),
                    onChanged: (texto) => _editarObservacao(index, texto),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // ✅ BOTÃO FINALIZAR
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _finalizarChecklist,
        icon: const Icon(Icons.check),
        label: const Text('Finalizar'),
      ),
    );
  }
}
