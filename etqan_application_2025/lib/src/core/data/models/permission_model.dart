import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';

class PermissionModel extends PermissionsView {
  PermissionModel({
    required super.userId,
    required super.fullNameEn,
    required super.fullNameAr,
    required super.email,
    required super.roleId,
    required super.roleNameEn,
    required super.roleNameAr,
    required super.permissionId,
    required super.permissionKey,
    required super.permissionDescriptionEn,
    required super.permissionDescriptionAr,
    super.departmentId,
    required super.allDepartments,
    super.endDate,
  });

  /// Factory constructor to create an instance from a Map object.
  factory PermissionModel.fromJson(Map<String, dynamic> map) {
    return PermissionModel(
      userId: map['user_id'] ?? '',
      fullNameEn: map['full_name_en'] ?? '',
      fullNameAr: map['full_name_ar'] ?? '',
      email: map['email'] ?? '',
      roleId: map['role_id'] ?? '',
      roleNameEn: map['role_name_en'] ?? '',
      roleNameAr: map['role_name_ar'] ?? '',
      permissionId: map['permission_id'] ?? '',
      permissionKey: map['permission_key'] ?? '',
      permissionDescriptionEn: map['permission_description_en'] ?? '',
      permissionDescriptionAr: map['permission_description_ar'] ?? '',
      departmentId: map['department_id'] ?? '',
      allDepartments: map['all_departments'] as bool,
      endDate:
          map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
    );
  }

  PermissionModel copyWith({
    String? userId,
    String? fullNameEn,
    String? fullNameAr,
    String? email,
    String? roleId,
    String? roleNameEn,
    String? roleNameAr,
    String? permissionId,
    String? permissionKey,
    String? permissionDescriptionEn,
    String? permissionDescriptionAr,
    String? departmentId,
    bool? allDepartments,
    DateTime? endDate,
  }) {
    return PermissionModel(
      userId: userId ?? this.userId,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      roleNameEn: roleNameEn ?? this.roleNameEn,
      roleNameAr: roleNameAr ?? this.roleNameAr,
      permissionId: permissionId ?? this.permissionId,
      permissionKey: permissionKey ?? this.permissionKey,
      permissionDescriptionEn:
          permissionDescriptionEn ?? this.permissionDescriptionEn,
      permissionDescriptionAr:
          permissionDescriptionAr ?? this.permissionDescriptionAr,
      departmentId: departmentId ?? this.departmentId,
      allDepartments: allDepartments ?? this.allDepartments,
      endDate: endDate ?? this.endDate,
    );
  }
}
