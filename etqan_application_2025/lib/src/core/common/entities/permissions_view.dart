class PermissionsView {
  final String userId;
  final String fullNameEn;
  final String fullNameAr;
  final String email;
  final String roleId;
  final String roleNameEn;
  final String roleNameAr;
  final String permissionId;
  final String permissionKey;
  final String permissionDescriptionEn;
  final String permissionDescriptionAr;
  final String? departmentId;
  final bool allDepartments;
  final DateTime? endDate;

  PermissionsView({
    required this.userId,
    required this.fullNameEn,
    required this.fullNameAr,
    required this.email,
    required this.roleId,
    required this.roleNameEn,
    required this.roleNameAr,
    required this.permissionId,
    required this.permissionKey,
    required this.permissionDescriptionEn,
    required this.permissionDescriptionAr,
    this.departmentId,
    required this.allDepartments,
    this.endDate,
  });
}
