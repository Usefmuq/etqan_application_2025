class AttendanceRegularizationViewEntity {
  final String id;
  final String createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final bool includeWeekends;
  final DateTime? proposedCheckIn;
  final DateTime? proposedCheckOut;
  final String reason;
  final String? status;
  final int requestId;
  final bool isActive;

  // User Details
  final String? fullNameEn;
  final String? fullNameAr;
  final String? email;
  final String? phone;
  final String? departmentId;
  final String? departmentNameEn;
  final String? departmentNameAr;
  final String? positionId;
  final String? positionNameEn;
  final String? positionNameAr;

  // Manager Details
  final String? reportTo;
  final String? reportToNameEn;
  final String? reportToNameAr;

  // Request Master Details
  final int? serviceId;
  final String? serviceNameEn;
  final String? serviceNameAr;
  final String? requestStatusId;
  final String? requestStatusKey;
  final String? requestStatusEn;
  final String? requestStatusAr;
  final String? priorityId;
  final String? priorityKey;
  final String? priorityEn;
  final String? priorityAr;
  final String? requestDetails;
  final DateTime? requestCreatedAt;
  final DateTime? requestUpdatedAt;
  final DateTime? requestApprovedAt;
  final bool requestIsActive;

  // Approval Metrics
  final int? numberOfManagerApprovalsNeeded;
  final int? numberOfApprovalsNeeded;
  final int numberOfApprovalsDone;
  final int numberOfApprovalsPending;

  AttendanceRegularizationViewEntity({
    required this.id,
    required this.createdById,
    this.createdAt,
    this.updatedAt,
    required this.startDate,
    required this.endDate,
    required this.includeWeekends,
    this.proposedCheckIn,
    this.proposedCheckOut,
    required this.reason,
    this.status,
    required this.requestId,
    required this.isActive,
    this.fullNameEn,
    this.fullNameAr,
    this.email,
    this.phone,
    this.departmentId,
    this.departmentNameEn,
    this.departmentNameAr,
    this.positionId,
    this.positionNameEn,
    this.positionNameAr,
    this.reportTo,
    this.reportToNameEn,
    this.reportToNameAr,
    this.serviceId,
    this.serviceNameEn,
    this.serviceNameAr,
    this.requestStatusId,
    this.requestStatusKey,
    this.requestStatusEn,
    this.requestStatusAr,
    this.priorityId,
    this.priorityKey,
    this.priorityEn,
    this.priorityAr,
    this.requestDetails,
    this.requestCreatedAt,
    this.requestUpdatedAt,
    this.requestApprovedAt,
    required this.requestIsActive,
    this.numberOfManagerApprovalsNeeded,
    this.numberOfApprovalsNeeded,
    required this.numberOfApprovalsDone,
    required this.numberOfApprovalsPending,
  });
}
