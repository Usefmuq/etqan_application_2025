import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';

class ApprovalSequenceViewModel {
  final int? approvalId;
  final int? requestId;
  final String? approverComment;
  final int? approvalOrder;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final bool? isActive;

  final String? approvalStatus;
  final String? approvalStatusKey;
  final String? approvalStatusEn;
  final String? approvalStatusAr;

  final String? roleId;
  final String? roleNameEn;
  final String? roleNameAr;

  final String? approverUserId;
  final String? approverNameEn;
  final String? approverNameAr;
  final String? approverEmail;

  final String? usersUnderRoleEn;
  final String? usersUnderRoleAr;
  final String? usersUnderRoleIds;
  final String? usersUnderRoleEmails;
  final String? approvedBy;
  final String? approvedByNameEn;
  final String? approvedByNameAr;
  final String? approvedByEmail;
  final String? requestStatusId;
  final String? requestStatusKey;
  final String? requestStatusEn;
  final String? requestStatusAr;
  final int? serviceId;
  final String? serviceNameEn;
  final String? serviceNameAr;

  final String? requestUserId;
  final String? requestUserNameEn;
  final String? requestUserNameAr;
  final String? requestUserEmail;

  ApprovalSequenceViewModel({
    this.approvalId,
    this.requestId,
    this.approverComment,
    this.approvalOrder,
    this.approvedAt,
    this.createdAt,
    this.isActive,
    this.approvalStatus,
    this.approvalStatusKey,
    this.approvalStatusEn,
    this.approvalStatusAr,
    this.roleId,
    this.roleNameEn,
    this.roleNameAr,
    this.approverUserId,
    this.approverNameEn,
    this.approverNameAr,
    this.approverEmail,
    this.usersUnderRoleEn,
    this.usersUnderRoleAr,
    this.usersUnderRoleIds,
    this.usersUnderRoleEmails,
    this.approvedBy,
    this.approvedByNameEn,
    this.approvedByNameAr,
    this.approvedByEmail,
    this.requestStatusId,
    this.requestStatusKey,
    this.requestStatusEn,
    this.requestStatusAr,
    this.serviceId,
    this.serviceNameEn,
    this.serviceNameAr,
    this.requestUserId,
    this.requestUserNameEn,
    this.requestUserNameAr,
    this.requestUserEmail,
  });

  factory ApprovalSequenceViewModel.fromJson(Map<String, dynamic> map) {
    return ApprovalSequenceViewModel(
      approvalId: map['approval_id'],
      requestId: map['request_id'],
      approverComment: map['approver_comment'],
      approvalOrder: map['approval_order'],
      approvedAt: map['approved_at'] != null
          ? DateTime.tryParse(map['approved_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      isActive: map['is_active'],
      approvalStatus: map['approval_status'],
      approvalStatusKey: map['approval_status_key'],
      approvalStatusEn: map['approval_status_en'],
      approvalStatusAr: map['approval_status_ar'],
      roleId: map['role_id'],
      roleNameEn: map['role_name_en'],
      roleNameAr: map['role_name_ar'],
      approverUserId: map['approver_user_id'],
      approverNameEn: map['approver_name_en'],
      approverNameAr: map['approver_name_ar'],
      approverEmail: map['approver_email'],
      usersUnderRoleEn: map['users_under_role_en'],
      usersUnderRoleAr: map['users_under_role_ar'],
      usersUnderRoleIds: map['users_under_role_ids'],
      usersUnderRoleEmails: map['users_under_role_emails'],
      approvedBy: map['approved_by'],
      approvedByNameEn: map['approved_by_name_en'],
      approvedByNameAr: map['approved_by_name_ar'],
      approvedByEmail: map['approved_by_email'],
      requestStatusId: map['request_status_id'],
      requestStatusKey: map['request_status_key'],
      requestStatusEn: map['request_status_en'],
      requestStatusAr: map['request_status_ar'],
      serviceId: map['service_id'],
      serviceNameEn: map['service_name_en'],
      serviceNameAr: map['service_name_ar'],
      requestUserId: map['request_user_id'],
      requestUserNameEn: map['request_user_name_en'],
      requestUserNameAr: map['request_user_name_ar'],
      requestUserEmail: map['request_user_email'],
    );
  }
  ApprovalSequenceViewModel copyWith({
    int? approvalId,
    int? requestId,
    String? approverComment,
    int? approvalOrder,
    DateTime? approvedAt,
    DateTime? createdAt,
    bool? isActive,
    String? approvalStatus,
    String? approvalStatusKey,
    String? approvalStatusEn,
    String? approvalStatusAr,
    String? roleId,
    String? roleNameEn,
    String? roleNameAr,
    String? approverUserId,
    String? approverNameEn,
    String? approverNameAr,
    String? approverEmail,
    String? usersUnderRoleEn,
    String? usersUnderRoleAr,
    String? usersUnderRoleIds,
    String? usersUnderRoleEmails,
    String? approvedBy,
    String? approvedByNameEn,
    String? approvedByNameAr,
    String? approvedByEmail,
    String? requestStatusId,
    String? requestStatusKey,
    String? requestStatusEn,
    String? requestStatusAr,
    int? serviceId,
    String? serviceNameEn,
    String? serviceNameAr,
    String? requestUserId,
    String? requestUserNameEn,
    String? requestUserNameAr,
    String? requestUserEmail,
  }) {
    return ApprovalSequenceViewModel(
      approvalId: approvalId ?? this.approvalId,
      requestId: requestId ?? this.requestId,
      approverComment: approverComment ?? this.approverComment,
      approvalOrder: approvalOrder ?? this.approvalOrder,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvalStatusKey: approvalStatusKey ?? this.approvalStatusKey,
      approvalStatusEn: approvalStatusEn ?? this.approvalStatusEn,
      approvalStatusAr: approvalStatusAr ?? this.approvalStatusAr,
      roleId: roleId ?? this.roleId,
      roleNameEn: roleNameEn ?? this.roleNameEn,
      roleNameAr: roleNameAr ?? this.roleNameAr,
      approverUserId: approverUserId ?? this.approverUserId,
      approverNameEn: approverNameEn ?? this.approverNameEn,
      approverNameAr: approverNameAr ?? this.approverNameAr,
      approverEmail: approverEmail ?? this.approverEmail,
      usersUnderRoleEn: usersUnderRoleEn ?? this.usersUnderRoleEn,
      usersUnderRoleAr: usersUnderRoleAr ?? this.usersUnderRoleAr,
      usersUnderRoleIds: usersUnderRoleIds ?? this.usersUnderRoleIds,
      usersUnderRoleEmails: usersUnderRoleEmails ?? this.usersUnderRoleEmails,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedByNameEn: approvedByNameEn ?? this.approvedByNameEn,
      approvedByNameAr: approvedByNameAr ?? this.approvedByNameAr,
      approvedByEmail: approvedByEmail ?? this.approvedByEmail,
      requestStatusId: requestStatusId ?? this.requestStatusId,
      requestStatusKey: requestStatusKey ?? this.requestStatusKey,
      requestStatusEn: requestStatusEn ?? this.requestStatusEn,
      requestStatusAr: requestStatusAr ?? this.requestStatusAr,
      serviceId: serviceId ?? this.serviceId,
      serviceNameEn: serviceNameEn ?? this.serviceNameEn,
      serviceNameAr: serviceNameAr ?? this.serviceNameAr,
      requestUserId: requestUserId ?? this.requestUserId,
      requestUserNameEn: requestUserNameEn ?? this.requestUserNameEn,
      requestUserNameAr: requestUserNameAr ?? this.requestUserNameAr,
      requestUserEmail: requestUserEmail ?? this.requestUserEmail,
    );
  }

  ApprovalSequence toApprovalSequence() {
    return ApprovalSequence(
      approvalId: approvalId,
      requestId: requestId ?? 0,
      roleId: roleId,
      approverUserId: approverUserId,
      approvedBy: approverUserId,
      approvalStatus: approvalStatus,
      approverComment: approverComment,
      approvalOrder: approvalOrder ?? 0,
      approvedAt: approvedAt,
      isActive: isActive ?? true,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 🧩 For CustomTableGrid
  Map<String, dynamic> toTableRow() {
    return {
      'Approval ID': approvalId,
      "رقم الموافقة": approvalId,
      'Request ID': requestId,
      'رقم الطلب': requestId,
      'Comment': approverComment ?? '',
      'Approval Order': approvalOrder,
      'Approved At': approvedAt,
      'تاريخ الموافقة': approvedAt,
      'Created At': createdAt,
      'تاريخ الإنشاء': createdAt,
      'Is Active': isActive,
      'Approval Status ID': approvalStatus,
      'حالة الموافقة': approvalStatus,
      'Approval Status': approvalStatus,
      'Approval Status Key': approvalStatusKey,
      'Approval Status EN': approvalStatusEn,
      'Approval Status AR': approvalStatusAr,
      'Role ID': roleId,
      'Approver Role': roleNameEn,
      'صفة المعتمد': roleNameAr,
      'Approver User ID': approverUserId,
      'Approver Name': approvedByNameEn ?? usersUnderRoleEn,
      'اسم المعتمد': approvedByNameAr ?? usersUnderRoleAr,
      'Approver Email': approverEmail,
      'Users Under Role EN': usersUnderRoleEn,
      'Users Under Role AR': usersUnderRoleAr,
      'Users Under Role IDs': usersUnderRoleIds,
      'Users Under Role Emails': usersUnderRoleEmails,
      'Approved By User ID': approvedBy,
      'Approved By Name EN': approvedByNameEn,
      'Approved By Name AR': approvedByNameAr,
      'Approved By Email': approvedByEmail,
      'Request Status ID': requestStatusId,
      'Request Status Key': requestStatusKey,
      'Request Status EN': requestStatusEn,
      'Request Status AR': requestStatusAr,
      'Service ID': serviceId,
      'Service Name EN': serviceNameEn,
      'Service Name AR': serviceNameAr,
      'Request User ID': requestUserId,
      'Request User Name EN': requestUserNameEn,
      'Request User Name AR': requestUserNameAr,
      'Request User Email': requestUserEmail,
    };
  }
}
