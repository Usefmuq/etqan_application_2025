class OnboardingsPageView {
  final int onboardingId;
  final String firstNameEn;
  final String lastNameEn;
  final String? firstNameAr;
  final String? lastNameAr;
  final String email;
  final String? phone;

  // Department Info
  final String? departmentId;
  final String? departmentNameEn;
  final String? departmentNameAr;

  // Position Info
  final String? positionId;
  final String? positionNameEn;
  final String? positionNameAr;

  // Manager Info
  final String? reportTo;
  final String? reportToNameEn;
  final String? reportToNameAr;

  final DateTime startDate;
  final String? notes;

  // Status
  final String? statusId;
  final String? statusKey;
  final String? statusEn;
  final String? statusAr;

  final String? createdBy;
  final String? createdByNameEn;
  final String? createdByNameAr;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  // Request Info
  final int? requestId;
  final String? requestStatusId;
  final String? requestStatusKey;
  final String? requestStatusEn;
  final String? requestStatusAr;
  final int? numberOfManagerApprovalsNeeded;
  final int? numberOfApprovalsNeeded;

  // Approval Summary
  final int numberOfApprovalsDone;
  final int numberOfApprovalsPending;

  OnboardingsPageView({
    required this.onboardingId,
    required this.firstNameEn,
    required this.lastNameEn,
    this.firstNameAr,
    this.lastNameAr,
    required this.email,
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
    required this.startDate,
    this.notes,
    this.statusId,
    this.statusKey,
    this.statusEn,
    this.statusAr,
    this.createdBy,
    this.createdByNameEn,
    this.createdByNameAr,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
    this.requestId,
    this.requestStatusId,
    this.requestStatusKey,
    this.requestStatusEn,
    this.requestStatusAr,
    this.numberOfManagerApprovalsNeeded,
    this.numberOfApprovalsNeeded,
    required this.numberOfApprovalsDone,
    required this.numberOfApprovalsPending,
  });
}
