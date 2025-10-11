class AttendancesPageView {
  final String? attendanceId;
  final String? createdById;
  final DateTime? attendanceUpdatedAt;
  final String? status;
  final bool? isActive;
  final String? title;
  final String? content;
  final List<String>? topics;

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

  final String? reportTo;
  final String? reportToNameEn;
  final String? reportToNameAr;

  final int? requestId;
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
  final bool? requestIsActive;

  final int? numberOfManagerApprovalsNeeded;
  final int? numberOfApprovalsNeeded;
  final int? numberOfApprovalsDone;
  final int? numberOfApprovalsPending;

  AttendancesPageView({
    this.attendanceId,
    this.title,
    this.content,
    this.status,
    this.isActive,
    this.topics,
    this.attendanceUpdatedAt,
    this.createdById,
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
    this.requestId,
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
    this.requestIsActive,
    this.numberOfManagerApprovalsNeeded,
    this.numberOfApprovalsNeeded,
    this.numberOfApprovalsDone,
    this.numberOfApprovalsPending,
  });
}
