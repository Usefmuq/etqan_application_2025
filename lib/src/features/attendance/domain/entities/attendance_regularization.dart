class AttendanceRegularization {
  final String id;
  final String createdById;
  final DateTime startDate;
  final DateTime endDate;
  final bool includeWeekends;
  final String? proposedCheckIn; // Format: "HH:mm" e.g. "08:00"
  final String? proposedCheckOut; // Format: "HH:mm" e.g. "17:00"
  final String? reason;

  AttendanceRegularization({
    required this.id,
    required this.createdById,
    required this.startDate,
    required this.endDate,
    required this.includeWeekends,
    this.proposedCheckIn,
    this.proposedCheckOut,
    this.reason,
  });
}
