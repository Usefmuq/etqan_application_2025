class ServiceApprovalUsers {
  final String id;
  final int serviceId;
  final String roleId; // Role required to approve
  final String? approverUserId; // Optional override with a specific user
  final int approvalOrder;
  final bool isActive;
  final DateTime createdAt;

  ServiceApprovalUsers({
    required this.id,
    required this.serviceId,
    required this.roleId,
    this.approverUserId,
    required this.approvalOrder,
    this.isActive = true,
    required this.createdAt,
  });
}
