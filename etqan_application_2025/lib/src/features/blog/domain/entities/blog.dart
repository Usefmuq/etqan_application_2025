class Blog {
  final String id;
  final String createdById;
  final DateTime updatedAt;
  final String title;
  final String content;
  final List<String> topics;
  final String? createdByName;

  Blog({
    required this.id,
    required this.createdById,
    required this.updatedAt,
    required this.title,
    required this.content,
    required this.topics,
    this.createdByName,
  });
}
