import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization.dart';

class AttendanceRegularizationModel extends AttendanceRegularization {
  AttendanceRegularizationModel({
    required super.id,
    required super.createdById,
    required super.startDate,
    required super.endDate,
    required super.includeWeekends,
    super.proposedCheckIn,
    super.proposedCheckOut,
    super.reason,
  });

  factory AttendanceRegularizationModel.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return AttendanceRegularizationModel(
      id: json['id'] ?? '',
      createdById: json['created_by_id'] ?? '',
      startDate: dt(json['start_date']) ?? DateTime.now(),
      endDate: dt(json['end_date']) ?? DateTime.now(),
      includeWeekends: (json['include_weekends'] ?? false) == true,
      proposedCheckIn: json['proposed_check_in']?.toString(),
      proposedCheckOut: json['proposed_check_out']?.toString(),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    String? ts(DateTime? d) => d?.toUtc().toIso8601String();

    return {
      'id': id,
      'created_by_id': createdById,
      'start_date': ts(startDate),
      'end_date': ts(endDate),
      'include_weekends': includeWeekends,
      'proposed_check_in': proposedCheckIn,
      'proposed_check_out': proposedCheckOut,
      'reason': reason,
    };
  }

  AttendanceRegularizationModel copyWith({
    String? id,
    String? createdById,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeWeekends,
    String? proposedCheckIn,
    String? proposedCheckOut,
    String? reason,
  }) {
    return AttendanceRegularizationModel(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeWeekends: includeWeekends ?? this.includeWeekends,
      proposedCheckIn: proposedCheckIn ?? this.proposedCheckIn,
      proposedCheckOut: proposedCheckOut ?? this.proposedCheckOut,
      reason: reason ?? this.reason,
    );
  }
}
