class ServiceMaster {
  final int serviceId;
  final String serviceNameEn;
  final String serviceNameAr;
  final String? serviceDescriptionEn;
  final String? serviceDescriptionAr;
  final bool isActive; // ✅ Whether the service is active
  final int?
      numberOfManagerApprovalsNeeded; // ✅ Number of manager approvals required
  final int? numberOfApprovalsNeeded; // ✅ Total approvals required
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceMaster({
    required this.serviceId,
    required this.serviceNameEn,
    required this.serviceNameAr,
    this.serviceDescriptionEn,
    this.serviceDescriptionAr,
    this.isActive = true, // ✅ Default: active
    this.numberOfManagerApprovalsNeeded =
        0, // ✅ Default: no manager approvals needed
    this.numberOfApprovalsNeeded = 0, // ✅ Default: no approvals needed
    required this.createdAt,
    required this.updatedAt,
  });
}
