class Inspection {
  final String id;
  final String userId;
  final DateTime date;
  final Map<String, dynamic> checklistData;
  final List<String> photoUrls;
  final String status;

  const Inspection({
    required this.id,
    required this.userId,
    required this.date,
    required this.checklistData,
    required this.photoUrls,
    required this.status,
  });
}

