class ApprovalSequence {
  final int? approvalId;
  final int requestId;
  final String? roleId; // Can be null if approver_user_id is used
  final String? approverUserId;
  final String? approvalStatus;
  final int approvalOrder;
  final DateTime? approvedAt;
  final bool isActive;
  final DateTime createdAt;

  ApprovalSequence({
    required this.approvalId,
    required this.requestId,
    this.roleId,
    this.approverUserId,
    this.approvalStatus,
    required this.approvalOrder,
    this.approvedAt,
    this.isActive = true,
    required this.createdAt,
  });
}
