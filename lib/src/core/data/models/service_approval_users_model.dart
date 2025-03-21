import 'package:etqan_application_2025/src/core/common/entities/service_approval_users.dart';

class ServiceApprovalUsersModel extends ServiceApprovalUsers {
  ServiceApprovalUsersModel({
    required super.id,
    required super.serviceId,
    required super.roleId,
    super.approverUserId,
    required super.approvalOrder,
    super.isActive = true,
    required super.createdAt,
  });

  /// ✅ From JSON
  factory ServiceApprovalUsersModel.fromJson(Map<String, dynamic> json) {
    return ServiceApprovalUsersModel(
      id: json['id'],
      serviceId: json['service_id'],
      roleId: json['role_id'],
      approverUserId: json['approver_user_id'],
      approvalOrder: json['approval_order'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// ✅ To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'role_id': roleId,
      'approver_user_id': approverUserId,
      'approval_order': approvalOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ✅ CopyWith
  ServiceApprovalUsersModel copyWith({
    String? id,
    int? serviceId,
    String? roleId,
    String? approverUserId,
    int? approvalOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServiceApprovalUsersModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      roleId: roleId ?? this.roleId,
      approverUserId: approverUserId ?? this.approverUserId,
      approvalOrder: approvalOrder ?? this.approvalOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
