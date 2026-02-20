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
