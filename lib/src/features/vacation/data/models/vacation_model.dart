import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation.dart';

class VacationModel extends Vacation {
  VacationModel({
    required super.id,
    required super.createdById,
    required super.updatedAt,
    required super.status,
    required super.requestId,
    required super.isActive,
    super.vacationTypeId,
    super.reason,
    super.startDate,
    super.endDate,
    super.daysCount,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_by_id': createdById,
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'request_id': requestId,
      'is_active': isActive,
      'vacation_type_id': vacationTypeId,
      'reason': reason,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'days_count': daysCount,
    };
  }

  factory VacationModel.fromJson(Map<String, dynamic> map) {
    return VacationModel(
      id: map['id'] as String,
      createdById: map['created_by_id'] as String,
      updatedAt: map['updated_at'] == null
          ? DateTime.now().toUtc().add(const Duration(hours: 3))
          : DateTime.parse(map['updated_at']),
      status: map['status'] as String,
      requestId: map['request_id'] as int,
      isActive: map['is_active'] as bool,
      vacationTypeId: map['vacation_type_id'] as String?,
      reason: map['reason'] as String?,
      startDate:
          map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      daysCount: map['days_count'] != null
          ? double.tryParse(map['days_count'].toString())
          : null,
    );
  }

  VacationModel copyWith({
    String? id,
    String? createdById,
    DateTime? updatedAt,
    String? status,
    int? requestId,
    bool? isActive,
    String? vacationTypeId,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
    double? daysCount,
  }) {
    return VacationModel(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      requestId: requestId ?? this.requestId,
      isActive: isActive ?? this.isActive,
      vacationTypeId: vacationTypeId ?? this.vacationTypeId,
      reason: reason ?? this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysCount: daysCount ?? this.daysCount,
    );
  }
}
