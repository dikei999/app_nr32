import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static final Box checklistBox = Hive.box('checklistBox');
  static final Box relatoriosBox = Hive.box('relatoriosBox');

  // ===============================
  // CHECKLIST (AGORA POR SETOR)
  // ===============================

  static List getChecklistItens(String chave) {
    return checklistBox.get(chave, defaultValue: []);
  }

  static Future<void> salvarChecklistItens(String chave, List itens) async {
    await checklistBox.put(chave, itens);
  }

  // ===============================
  // RELATÓRIOS
  // ===============================

  static List getRelatorios() {
    return relatoriosBox.get('relatorios', defaultValue: []);
  }

  static Future<void> salvarRelatorios(List relatorios) async {
    await relatoriosBox.put('relatorios', relatorios);
  }
}
