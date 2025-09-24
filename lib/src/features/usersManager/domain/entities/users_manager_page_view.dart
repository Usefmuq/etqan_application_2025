class UsersManagerPageView {
  // Entity
  final int requestId;
  final String userId;
  final String roleId;
  final String? roleNameEn;
  final String? roleNameAr;
  final bool appliesToAllDepartments;
  final String? departmentId;
  final String? departmentNameEn;
  final String? departmentNameAr;
  final DateTime startAt;
  final DateTime? endAt;
  final String action; // 'ADD' | 'REMOVE'
  final String? terminatedBy;
  final DateTime? terminatedAt;
  final String? terminationReason;
  final String? notes;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Creator (like blogs view)
  final String? fullNameEn;
  final String? fullNameAr;
  final String? email;
  final String? phone;
  final String? creatorDepartmentId;
  final String? creatorDepartmentNameEn;
  final String? creatorDepartmentNameAr;
  final String? creatorPositionId;
  final String? creatorPositionNameEn;
  final String? creatorPositionNameAr;
  final String? reportTo;
  final String? reportToNameEn;
  final String? reportToNameAr;

  // Request + service
  final int serviceId;
  final String? serviceNameEn;
  final String? serviceNameAr;
  final String requestStatusId;
  final String? requestStatusKey;
  final String? requestStatusEn;
  final String? requestStatusAr;
  final String? priorityId;
  final String? priorityKey;
  final String? priorityEn;
  final String? priorityAr;
  final Map<String, dynamic>? requestDetails;
  final DateTime requestCreatedAt;
  final DateTime requestUpdatedAt;
  final DateTime? requestApprovedAt;
  final bool requestIsActive;
  final int? numberOfManagerApprovalsNeeded;
  final int? numberOfApprovalsNeeded;
  final int numberOfApprovalsDone;
  final int numberOfApprovalsPending;

  UsersManagerPageView({
    // entity
    required this.requestId,
    required this.userId,
    required this.roleId,
    this.roleNameEn,
    this.roleNameAr,
    required this.appliesToAllDepartments,
    this.departmentId,
    this.departmentNameEn,
    this.departmentNameAr,
    required this.startAt,
    this.endAt,
    required this.action,
    this.terminatedBy,
    this.terminatedAt,
    this.terminationReason,
    this.notes,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    // creator
    this.fullNameEn,
    this.fullNameAr,
    this.email,
    this.phone,
    this.creatorDepartmentId,
    this.creatorDepartmentNameEn,
    this.creatorDepartmentNameAr,
    this.creatorPositionId,
    this.creatorPositionNameEn,
    this.creatorPositionNameAr,
    this.reportTo,
    this.reportToNameEn,
    this.reportToNameAr,
    // request
    required this.serviceId,
    this.serviceNameEn,
    this.serviceNameAr,
    required this.requestStatusId,
    this.requestStatusKey,
    this.requestStatusEn,
    this.requestStatusAr,
    this.priorityId,
    this.priorityKey,
    this.priorityEn,
    this.priorityAr,
    this.requestDetails,
    required this.requestCreatedAt,
    required this.requestUpdatedAt,
    this.requestApprovedAt,
    required this.requestIsActive,
    this.numberOfManagerApprovalsNeeded,
    this.numberOfApprovalsNeeded,
    required this.numberOfApprovalsDone,
    required this.numberOfApprovalsPending,
  });
}
