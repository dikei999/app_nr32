import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DemoInspectionStorageService {
  static const _uuid = Uuid();

  Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory('${dir.path}${Platform.pathSeparator}demo_inspecoes');
    if (!await base.exists()) {
      await base.create(recursive: true);
    }
    return base;
  }

  Future<String> saveInspectionJson({
    required Map<String, dynamic> payload,
  }) async {
    final base = await _baseDir();
    final id = _uuid.v4();
    final file = File('${base.path}${Platform.pathSeparator}$id.json');
    await file.writeAsString(jsonEncode(payload));
    return file.path;
  }

  Future<List<FileSystemEntity>> listInspections() async {
    final base = await _baseDir();
    final files = base
        .listSync()
        .where((e) => e.path.toLowerCase().endsWith('.json'))
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }
}

