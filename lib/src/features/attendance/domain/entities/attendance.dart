class Attendance {
  final String id;
  final String createdById;
  final DateTime updatedAt;
  final String status;
  final int requestId;
  final bool isActive;
  final String title;
  final String content;
  final List<String> topics;
  final String? createdByName;

  Attendance({
    required this.id,
    required this.createdById,
    required this.updatedAt,
    required this.status,
    required this.requestId,
    required this.isActive,
    required this.title,
    required this.content,
    required this.topics,
    this.createdByName,
  });
}
