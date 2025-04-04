class Onboarding {
  final int? onboardingId;
  final String firstNameEn;
  final String lastNameEn;
  final String? firstNameAr;
  final String? lastNameAr;
  final String email;
  final String? phone;

  // Job Info
  final String? departmentId;
  final String? positionId;
  final String? reportTo;
  final DateTime startDate;

  // Meta
  final String? status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  // Request / Approval flow
  final int? requestId;
  final String? notes;

  Onboarding({
    this.onboardingId,
    required this.firstNameEn,
    required this.lastNameEn,
    this.firstNameAr,
    this.lastNameAr,
    required this.email,
    this.phone,
    this.departmentId,
    this.positionId,
    this.reportTo,
    required this.startDate,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.requestId,
    this.notes,
  });
}
