import 'package:etqan_application_2025/src/core/common/entities/service_master.dart';

class ServiceMasterModel extends ServiceMaster {
  ServiceMasterModel({
    required super.serviceId,
    required super.serviceNameEn,
    required super.serviceNameAr,
    super.serviceDescriptionEn,
    super.serviceDescriptionAr,
    super.isActive = true, // ✅ Default: active
    super.numberOfManagerApprovalsNeeded = 0, // ✅ Default: no manager approvals
    super.numberOfApprovalsNeeded = 0, // ✅ Default: no approvals
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory constructor to create an instance from a Map object.
  factory ServiceMasterModel.fromJson(Map<String, dynamic> map) {
    return ServiceMasterModel(
      serviceId: map['service_id'] as int,
      serviceNameEn: map['service_name_en'] ?? '',
      serviceNameAr: map['service_name_ar'] ?? '',
      serviceDescriptionEn: map['service_description_en'],
      serviceDescriptionAr: map['service_description_ar'],
      isActive: map['is_active'] ?? true,
      numberOfManagerApprovalsNeeded:
          map['number_of_manager_approvals_needed'] ?? 0,
      numberOfApprovalsNeeded: map['number_of_approvals_needed'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  ServiceMasterModel copyWith({
    int? serviceId,
    String? serviceNameEn,
    String? serviceNameAr,
    String? serviceDescriptionEn,
    String? serviceDescriptionAr,
    bool? isActive,
    int? numberOfManagerApprovalsNeeded,
    int? numberOfApprovalsNeeded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceMasterModel(
      serviceId: serviceId ?? this.serviceId,
      serviceNameEn: serviceNameEn ?? this.serviceNameEn,
      serviceNameAr: serviceNameAr ?? this.serviceNameAr,
      serviceDescriptionEn: serviceDescriptionEn ?? this.serviceDescriptionEn,
      serviceDescriptionAr: serviceDescriptionAr ?? this.serviceDescriptionAr,
      isActive: isActive ?? this.isActive,
      numberOfManagerApprovalsNeeded:
          numberOfManagerApprovalsNeeded ?? this.numberOfManagerApprovalsNeeded,
      numberOfApprovalsNeeded:
          numberOfApprovalsNeeded ?? this.numberOfApprovalsNeeded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
