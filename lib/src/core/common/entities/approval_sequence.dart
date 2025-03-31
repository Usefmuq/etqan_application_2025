class ApprovalSequence {
  final int? approvalId;
  final int requestId;
  final String? roleId; // Can be null if approver_user_id is used
  final String? approverUserId;
  final String? approvedBy;
  final String? approvalStatus;
  final String? approverComment;
  final int approvalOrder;
  final DateTime? approvedAt;
  final bool isActive;
  final DateTime createdAt;

  ApprovalSequence({
    this.approvalId,
    required this.requestId,
    this.roleId,
    this.approverUserId,
    this.approvedBy,
    this.approvalStatus,
    this.approverComment,
    required this.approvalOrder,
    this.approvedAt,
    this.isActive = true,
    required this.createdAt,
  });
}
