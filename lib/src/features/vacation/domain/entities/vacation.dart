class Vacation {
  final String id;
  final String createdById;
  final DateTime updatedAt;
  final String status;
  final int requestId;
  final bool isActive;

  // New Fields
  final String? vacationTypeId;
  final String? reason;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? daysCount;

  Vacation({
    required this.id,
    required this.createdById,
    required this.updatedAt,
    required this.status,
    required this.requestId,
    required this.isActive,
    this.vacationTypeId,
    this.reason,
    this.startDate,
    this.endDate,
    this.daysCount,
  });
}
