class ApprovalSequenceView {
  final int? approvalId;
  final int? requestId;
  final String? approverComment;
  final int? approvalOrder;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final bool? isActive;

  // Approval Status
  final String? approvalStatus;
  final String? approvalStatusKey;
  final String? approvalStatusEn;
  final String? approvalStatusAr;

  // Role Info
  final String? roleId;
  final String? roleNameEn;
  final String? roleNameAr;

  // Approver Info
  final String? approverUserId;
  final String? approverNameEn;
  final String? approverNameAr;
  final String? approverEmail;

  // List of users under role
  final String? usersUnderRoleEn;
  final String? usersUnderRoleAr;
  final String? usersUnderRoleIds;
  final String? usersUnderRoleEmails;

  final String? approvedBy;
  final String? approvedByNameEn;
  final String? approvedByNameAr;
  final String? approvedByEmail;

  // Request Info
  final String? requestStatusId;
  final String? requestStatusKey;
  final String? requestStatusEn;
  final String? requestStatusAr;
  final int? serviceId;
  final String? serviceNameEn;
  final String? serviceNameAr;

  // Request Creator Info
  final String? requestUserId;
  final String? requestUserNameEn;
  final String? requestUserNameAr;
  final String? requestUserEmail;

  ApprovalSequenceView({
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
}
