import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'tela_detalhe_relatorio.dart';

class TelaRelatorios extends StatefulWidget {
  const TelaRelatorios({super.key});

  @override
  State<TelaRelatorios> createState() => _TelaRelatoriosState();
}

class _TelaRelatoriosState extends State<TelaRelatorios> {
  List relatorios = [];

  @override
  void initState() {
    super.initState();
    _carregarRelatorios();
  }

  void _carregarRelatorios() {
    relatorios = LocalStorageService.getRelatorios();
    setState(() {});
  }

  String _formatarData(String dataIso) {
    final data = DateTime.parse(dataIso);
    return "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year} "
        "${data.hour.toString().padLeft(2, '0')}:"
        "${data.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios Salvos')),
      body: relatorios.isEmpty
          ? const Center(child: Text('Nenhum relatório salvo'))
          : ListView.builder(
              itemCount: relatorios.length,
              itemBuilder: (context, index) {
                final relatorio = relatorios[index];

                return ListTile(
                  title: Text('Relatório - ${relatorio["setor"]}'),
                  subtitle: Text(relatorio["data"] ?? 'Sem data'),
                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TelaDetalheRelatorio(relatorio: relatorio),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
