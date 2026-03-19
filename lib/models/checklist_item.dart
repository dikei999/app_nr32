class CheckListItem {
  final String id;
  final String nr32Section;
  final String itemDescription;
  final bool isRequiredPhoto;
  final int order;

  const CheckListItem({
    required this.id,
    required this.nr32Section,
    required this.itemDescription,
    required this.isRequiredPhoto,
    required this.order,
  });

  factory CheckListItem.fromMap(Map<String, dynamic> map) {
    return CheckListItem(
      id: map['id'].toString(),
      nr32Section: (map['nr32_section'] ?? '').toString(),
      itemDescription: (map['item_description'] ?? '').toString(),
      isRequiredPhoto: (map['is_required_photo'] ?? false) as bool,
      order: (map['order'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nr32_section': nr32Section,
      'item_description': itemDescription,
      'is_required_photo': isRequiredPhoto,
      'order': order,
    };
  }
}

class ChecklistItem {
  final String titulo;
  final bool obrigatorio;
  bool concluido;

  ChecklistItem({
    required this.titulo,
    this.obrigatorio = true,
    this.concluido = false,
  });
}
