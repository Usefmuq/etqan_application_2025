import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager.dart';

class UsersManagerModel extends UsersManager {
  UsersManagerModel({
    required super.requestId,
    required super.userId,
    required super.roleId,
    required super.appliesToAllDepartments,
    super.departmentId,
    required super.startAt,
    super.endAt,
    required super.action,
    super.terminatedBy,
    super.terminatedAt,
    super.terminationReason,
    super.notes,
    required super.createdById,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UsersManagerModel.fromJson(Map<String, dynamic> json) {
    return UsersManagerModel(
      requestId: json['request_id'],
      userId: json['user_id'],
      roleId: json['role_id'],
      appliesToAllDepartments: json['applies_to_all_departments'],
      departmentId: json['department_id'],
      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] != null ? DateTime.tryParse(json['end_at']) : null,
      action: json['action'],
      terminatedBy: json['terminated_by'],
      terminatedAt: json['terminated_at'] != null
          ? DateTime.tryParse(json['terminated_at'])
          : null,
      terminationReason: json['termination_reason'],
      notes: json['notes'],
      createdById: json['created_by_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'role_id': roleId,
      'applies_to_all_departments': appliesToAllDepartments,
      'department_id': departmentId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'action': action,
      'terminated_by': terminatedBy,
      'terminated_at': terminatedAt?.toIso8601String(),
      'termination_reason': terminationReason,
      'notes': notes,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UsersManagerModel copyWith({
    int? requestId,
    String? userId,
    String? roleId,
    bool? appliesToAllDepartments,
    String? departmentId,
    DateTime? startAt,
    DateTime? endAt,
    String? action,
    String? terminatedBy,
    DateTime? terminatedAt,
    String? terminationReason,
    String? notes,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsersManagerModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      appliesToAllDepartments:
          appliesToAllDepartments ?? this.appliesToAllDepartments,
      departmentId: departmentId ?? this.departmentId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      action: action ?? this.action,
      terminatedBy: terminatedBy ?? this.terminatedBy,
      terminatedAt: terminatedAt ?? this.terminatedAt,
      terminationReason: terminationReason ?? this.terminationReason,
      notes: notes ?? this.notes,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  UsersManager toUsersManager() {
    return UsersManager(
      requestId: requestId,
      userId: userId,
      roleId: roleId,
      appliesToAllDepartments: appliesToAllDepartments,
      departmentId: departmentId,
      startAt: startAt,
      endAt: endAt,
      action: action,
      terminatedBy: terminatedBy,
      terminatedAt: terminatedAt,
      terminationReason: terminationReason,
      notes: notes,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
