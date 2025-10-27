// attendance_session_model.dart
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_session.dart';

class AttendanceSessionModel extends AttendanceSession {
  AttendanceSessionModel({
    required super.id,
    required super.userId,
    required super.sourceKey,
    super.siteId,
    super.insideSite,
    required super.startAt,
    super.endAt,
    super.note,
    super.startLat,
    super.startLng,
    super.startAccuracyM,
    super.endLat,
    super.endLng,
    super.endAccuracyM,
    super.createdAt,
    super.updatedAt,
    super.isActive = true,
    super.workDateLocal,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    double? _num(dynamic v) => v == null
        ? null
        : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    return AttendanceSessionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      sourceKey: json['source_key'] ?? 'auto',
      siteId: json['site_id'],
      insideSite: json['inside_site'],
      startAt: _dt(json['start_at']) ?? DateTime.now(),
      endAt: _dt(json['end_at']),
      note: json['note'],
      startLat: _num(json['start_lat']),
      startLng: _num(json['start_lng']),
      startAccuracyM: _num(json['start_accuracy_m']),
      endLat: _num(json['end_lat']),
      endLng: _num(json['end_lng']),
      endAccuracyM: _num(json['end_accuracy_m']),
      createdAt: _dt(json['created_at']),
      updatedAt: _dt(json['updated_at']),
      isActive: (json['is_active'] ?? true) == true,
      workDateLocal: _dt(json['work_date_local']),
    );
  }

  Map<String, dynamic> toJson() {
    String? _ts(DateTime? d) => d?.toUtc().toIso8601String();

    return {
      'id': id,
      'user_id': userId,
      'source_key': sourceKey,
      'site_id': siteId,
      'inside_site': insideSite,
      'start_at': _ts(startAt),
      'end_at': _ts(endAt),
      'note': note,
      'start_lat': startLat,
      'start_lng': startLng,
      'start_accuracy_m': startAccuracyM,
      'end_lat': endLat,
      'end_lng': endLng,
      'end_accuracy_m': endAccuracyM,
      'created_at': _ts(createdAt),
      'updated_at': _ts(updatedAt),
      'is_active': isActive,
      // 'work_date_local' is generated; usually don’t send it back
    };
  }

  AttendanceSessionModel copyWith({
    String? id,
    String? userId,
    String? sourceKey,
    String? siteId,
    bool? insideSite,
    DateTime? startAt,
    DateTime? endAt,
    String? note,
    double? startLat,
    double? startLng,
    double? startAccuracyM,
    double? endLat,
    double? endLng,
    double? endAccuracyM,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    DateTime? workDateLocal,
  }) {
    return AttendanceSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sourceKey: sourceKey ?? this.sourceKey,
      siteId: siteId ?? this.siteId,
      insideSite: insideSite ?? this.insideSite,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      note: note ?? this.note,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      startAccuracyM: startAccuracyM ?? this.startAccuracyM,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      endAccuracyM: endAccuracyM ?? this.endAccuracyM,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      workDateLocal: workDateLocal ?? this.workDateLocal,
    );
  }

  Map<String, dynamic> toTableRow() {
    return {
      'Source': sourceKey,
      'Start': startAt,
      'End': endAt,
      'Start (lat,lng)': (startLat != null && startLng != null)
          ? '${startLat!.toStringAsFixed(6)}, ${startLng!.toStringAsFixed(6)}'
          : '—',
      'End (lat,lng)': (endLat != null && endLng != null)
          ? '${endLat!.toStringAsFixed(6)}, ${endLng!.toStringAsFixed(6)}'
          : '—',
      'Accuracy(m)': [
        if (startAccuracyM != null) startAccuracyM!.toStringAsFixed(0),
        if (endAccuracyM != null) endAccuracyM!.toStringAsFixed(0),
      ].join(' / '),
      'Inside Site': insideSite == true ? 'Yes' : 'No',
      'Note': note ?? '',
      'Active': isActive,
    };
  }
}
