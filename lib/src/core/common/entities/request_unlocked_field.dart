class RequestUnlockedField {
  final String id;
  final int requestId;
  final String fieldKey;
  final String unlockedBy;
  final DateTime unlockedAt;
  final String? reason;
  final bool isActive;

  RequestUnlockedField({
    required this.id,
    required this.requestId,
    required this.fieldKey,
    required this.unlockedBy,
    required this.unlockedAt,
    this.reason,
    required this.isActive,
  });
}
