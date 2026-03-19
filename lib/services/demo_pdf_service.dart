import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class DemoPdfService {
  static const _uuid = Uuid();

  Future<String> generateInspectionPdf({
    required String organizationName,
    required String inspectorName,
    required DateTime date,
    required List<Map<String, dynamic>> answeredItems,
  }) async {
    final doc = pw.Document();
    final df = DateFormat('dd/MM/yyyy HH:mm');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Relatório de Inspeção (DEMO)',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Organização: $organizationName'),
          pw.Text('Inspetor: $inspectorName'),
          pw.Text('Data: ${df.format(date)}'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Itens respondidos',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...answeredItems.map(
            (e) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 6),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${e['nr32_section']}'),
                  pw.Text('${e['item_description']}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Conforme: ${e['checked'] == true ? 'Sim' : 'Não'}'),
                  if ((e['note'] ?? '').toString().isNotEmpty)
                    pw.Text('Observação: ${e['note']}'),
                  if (e['photo_mock'] == true)
                    pw.Text('Foto: (mock/demo)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final base = Directory('${dir.path}${Platform.pathSeparator}demo_pdfs');
    if (!await base.exists()) await base.create(recursive: true);

    final id = _uuid.v4();
    final file = File('${base.path}${Platform.pathSeparator}$id.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }
}

