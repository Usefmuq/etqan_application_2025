import 'package:etqan_application_2025/src/core/common/entities/user_roles.dart';

class UserRolesModel extends UserRoles {
  UserRolesModel({
    required super.userId,
    required super.roleId,
    super.departmentId,
    super.allDepartments = false,
    super.startDate,
    super.endDate,
    super.assignedBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserRolesModel.fromJson(Map<String, dynamic> json) {
    return UserRolesModel(
      userId: json['user_id'],
      roleId: json['role_id'],
      departmentId: json['department_id'],
      allDepartments: json['all_departments'] ?? false,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      assignedBy: json['assigned_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'department_id': departmentId,
      'all_departments': allDepartments,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'assigned_by': assignedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserRolesModel copyWith({
    String? userId,
    String? roleId,
    String? departmentId,
    bool? allDepartments,
    DateTime? startDate,
    DateTime? endDate,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserRolesModel(
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      departmentId: departmentId ?? this.departmentId,
      allDepartments: allDepartments ?? this.allDepartments,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      assignedBy: assignedBy ?? this.assignedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
