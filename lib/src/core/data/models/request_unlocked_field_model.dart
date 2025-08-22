import 'package:etqan_application_2025/src/core/common/entities/request_unlocked_field.dart';

class RequestUnlockedFieldModel extends RequestUnlockedField {
  RequestUnlockedFieldModel({
    required super.id,
    required super.requestId,
    required super.fieldKey,
    required super.unlockedBy,
    required super.unlockedAt,
    super.reason,
    required super.isActive,
  });

  factory RequestUnlockedFieldModel.fromJson(Map<String, dynamic> json) {
    return RequestUnlockedFieldModel(
      id: json['id'],
      requestId: json['request_id'],
      fieldKey: json['field_key'],
      unlockedBy: json['unlocked_by'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
      reason: json['reason'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      // 'id': id,
      'request_id': requestId,
      'field_key': fieldKey,
      'unlocked_by': unlockedBy,
      'unlocked_at': unlockedAt.toIso8601String(),
      'reason': reason,
      'is_active': isActive,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  RequestUnlockedFieldModel copyWith({
    String? id,
    int? requestId,
    String? fieldKey,
    String? unlockedBy,
    DateTime? unlockedAt,
    String? reason,
    bool? isActive,
  }) {
    return RequestUnlockedFieldModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      fieldKey: fieldKey ?? this.fieldKey,
      unlockedBy: unlockedBy ?? this.unlockedBy,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      reason: reason ?? this.reason,
      isActive: isActive ?? this.isActive,
    );
  }
}
