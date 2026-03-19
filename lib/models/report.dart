class Report {
  final String id;
  final String period;
  final DateTime generatedAt;
  final String? pdfUrl;
  final bool sentToEngineer;

  const Report({
    required this.id,
    required this.period,
    required this.generatedAt,
    required this.pdfUrl,
    required this.sentToEngineer,
  });
}

