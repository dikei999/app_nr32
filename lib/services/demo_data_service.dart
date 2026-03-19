import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/checklist_item.dart';

class DemoDataService {
  Future<List<CheckListItem>> loadChecklistItems() async {
    final raw = await rootBundle.loadString('assets/demo/checklist_items.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => CheckListItem.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}

