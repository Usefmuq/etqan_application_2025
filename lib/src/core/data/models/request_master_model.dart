import 'package:etqan_application_2025/src/core/common/entities/request_master.dart';

class RequestMasterModel extends RequestMaster {
  RequestMasterModel({
    super.requestId,
    required super.userId,
    required super.serviceId,
    super.status,
    super.priority,
    super.requestDetails,
    super.isActive = true, // ✅ Default: active
    required super.createdAt,
    required super.updatedAt,
    super.approvedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // 'request_id': requestId,
      'user_id': userId,
      'service_id': serviceId,
      'status': status,
      'priority': priority,
      'request_details': requestDetails,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(), // ✅ Nullable field
    };
  }

  /// Factory constructor to create an instance from a Map object.
  factory RequestMasterModel.fromJson(Map<String, dynamic> map) {
    return RequestMasterModel(
      requestId: map['request_id'] ?? '',
      userId: map['user_id'] ?? '',
      serviceId: map['service_id'] ?? '',
      status: map['status'],
      priority: map['priority'],
      requestDetails: map['request_details'],
      isActive: map['is_active'] as bool,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      approvedAt: map['approved_at'] != null
          ? DateTime.tryParse(map['approved_at'])
          : null,
    );
  }

  RequestMasterModel copyWith({
    int? requestId,
    String? userId,
    int? serviceId,
    String? status,
    String? priority,
    String? requestDetails,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
  }) {
    return RequestMasterModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      requestDetails: requestDetails ?? this.requestDetails,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
