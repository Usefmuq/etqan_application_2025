class UsersManager {
  final int requestId;
  final String userId;
  final String roleId;

  // Department scope
  final bool appliesToAllDepartments;
  final String? departmentId;

  // Validity window
  final DateTime startAt;
  final DateTime? endAt;

  // Lifecycle
  final String action; // 'ADD' or 'REMOVE'

  final String? terminatedBy;
  final DateTime? terminatedAt;
  final String? terminationReason;

  // Metadata
  final String? notes;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  UsersManager({
    required this.requestId,
    required this.userId,
    required this.roleId,
    required this.appliesToAllDepartments,
    this.departmentId,
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
  });
}
