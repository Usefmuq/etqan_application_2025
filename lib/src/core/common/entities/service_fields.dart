class ServiceField {
  final int serviceFieldId;
  final int serviceId;
  final String fieldKey;
  final String fieldLabelEn;
  final String? fieldLabelAr;
  final String fieldType;
  final bool isRequired;
  final bool isEditable;
  final bool isActive;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  ServiceField({
    required this.serviceFieldId,
    required this.serviceId,
    required this.fieldKey,
    required this.fieldLabelEn,
    this.fieldLabelAr,
    required this.fieldType,
    required this.isRequired,
    required this.isEditable,
    required this.isActive,
    required this.orderIndex,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory ServiceField.fromJson(Map<String, dynamic> json) {
    return ServiceField(
      serviceFieldId: json['service_field_id'],
      serviceId: json['service_id'],
      fieldKey: json['field_key'],
      fieldLabelEn: json['field_label_en'],
      fieldLabelAr: json['field_label_ar'],
      fieldType: json['field_type'],
      isRequired: json['is_required'] ?? false,
      isEditable: json['is_editable'] ?? true,
      isActive: json['is_active'] ?? true,
      orderIndex: json['order_index'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_field_id': serviceFieldId,
      'service_id': serviceId,
      'field_key': fieldKey,
      'field_label_en': fieldLabelEn,
      'field_label_ar': fieldLabelAr,
      'field_type': fieldType,
      'is_required': isRequired,
      'is_editable': isEditable,
      'is_active': isActive,
      'order_index': orderIndex,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  ServiceField copyWith({
    int? serviceFieldId,
    int? serviceId,
    String? fieldKey,
    String? fieldLabelEn,
    String? fieldLabelAr,
    String? fieldType,
    bool? isRequired,
    bool? isEditable,
    bool? isActive,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ServiceField(
      serviceFieldId: serviceFieldId ?? this.serviceFieldId,
      serviceId: serviceId ?? this.serviceId,
      fieldKey: fieldKey ?? this.fieldKey,
      fieldLabelEn: fieldLabelEn ?? this.fieldLabelEn,
      fieldLabelAr: fieldLabelAr ?? this.fieldLabelAr,
      fieldType: fieldType ?? this.fieldType,
      isRequired: isRequired ?? this.isRequired,
      isEditable: isEditable ?? this.isEditable,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
