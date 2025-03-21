import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';

class ApprovalSequenceModel extends ApprovalSequence {
  ApprovalSequenceModel({
    super.approvalId,
    required super.requestId,
    super.roleId,
    super.approverUserId,
    super.approvalStatus,
    super.approverComment,
    required super.approvalOrder,
    super.approvedAt,
    super.isActive = true,
    required super.createdAt,
  });

  factory ApprovalSequenceModel.fromJson(Map<String, dynamic> json) {
    return ApprovalSequenceModel(
      approvalId: json['approval_id'],
      requestId: json['request_id'],
      roleId: json['role_id'],
      approverUserId: json['approver_user_id'],
      approvalStatus: json['approval_status'],
      approverComment: json['approver_comment'],
      approvalOrder: json['approval_order'],
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'approval_id': approvalId,
      'request_id': requestId,
      'role_id': roleId,
      'approver_user_id': approverUserId,
      'approval_status': approvalStatus,
      'approver_comment': approverComment,
      'approval_order': approvalOrder,
      'approved_at': approvedAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ApprovalSequenceModel copyWith({
    int? approvalId,
    int? requestId,
    String? roleId,
    String? approverUserId,
    String? approvalStatus,
    String? approverComment,
    int? approvalOrder,
    DateTime? approvedAt,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ApprovalSequenceModel(
      approvalId: approvalId ?? this.approvalId,
      requestId: requestId ?? this.requestId,
      roleId: roleId ?? this.roleId,
      approverUserId: approverUserId ?? this.approverUserId,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approverComment: approverComment ?? this.approverComment,
      approvalOrder: approvalOrder ?? this.approvalOrder,
      approvedAt: approvedAt ?? this.approvedAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
