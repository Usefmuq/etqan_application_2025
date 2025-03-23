class UserRoles {
  final String userId;
  final String roleId;
  final String? departmentId;
  final bool allDepartments;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? assignedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserRoles({
    required this.userId,
    required this.roleId,
    this.departmentId,
    this.allDepartments = false,
    this.startDate,
    this.endDate,
    this.assignedBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
