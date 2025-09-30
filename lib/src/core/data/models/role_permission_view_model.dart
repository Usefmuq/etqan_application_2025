// role_permission_view.dart

class RolePermissionView {
  final String roleId;
  final String roleNameEn;
  final String roleNameAr;
  final String? parentRoleId;
  final String? roleDescriptionEn;
  final String? roleDescriptionAr;
  final DateTime? roleCreatedAt;
  final DateTime? roleUpdatedAt;

  final String permissionId;
  final String permissionKey;
  final String permissionDescriptionEn;
  final String permissionDescriptionAr;
  final String permissionCategoryEn;
  final String permissionCategoryAr;
  final DateTime? permissionCreatedAt;
  final DateTime? permissionUpdatedAt;

  final String? assignedBy;
  final String? assignedByEmail;
  final String? assignedByFullNameEn;
  final String? assignedByFullNameAr;
  final DateTime? assignedAt;

  RolePermissionView({
    required this.roleId,
    required this.roleNameEn,
    required this.roleNameAr,
    this.parentRoleId,
    this.roleDescriptionEn,
    this.roleDescriptionAr,
    this.roleCreatedAt,
    this.roleUpdatedAt,
    required this.permissionId,
    required this.permissionKey,
    required this.permissionDescriptionEn,
    required this.permissionDescriptionAr,
    required this.permissionCategoryEn,
    required this.permissionCategoryAr,
    this.permissionCreatedAt,
    this.permissionUpdatedAt,
    this.assignedBy,
    this.assignedByEmail,
    this.assignedByFullNameEn,
    this.assignedByFullNameAr,
    this.assignedAt,
  });
}

class RolePermissionViewModel extends RolePermissionView {
  RolePermissionViewModel({
    required super.roleId,
    required super.roleNameEn,
    required super.roleNameAr,
    super.parentRoleId,
    super.roleDescriptionEn,
    super.roleDescriptionAr,
    super.roleCreatedAt,
    super.roleUpdatedAt,
    required super.permissionId,
    required super.permissionKey,
    required super.permissionDescriptionEn,
    required super.permissionDescriptionAr,
    required super.permissionCategoryEn,
    required super.permissionCategoryAr,
    super.permissionCreatedAt,
    super.permissionUpdatedAt,
    super.assignedBy,
    super.assignedByEmail,
    super.assignedByFullNameEn,
    super.assignedByFullNameAr,
    super.assignedAt,
  });

  factory RolePermissionViewModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionViewModel(
      roleId: json['role_id'] ?? '',
      roleNameEn: json['role_name_en'] ?? '',
      roleNameAr: json['role_name_ar'] ?? '',
      parentRoleId: json['parent_role_id'],
      roleDescriptionEn: json['role_description_en'],
      roleDescriptionAr: json['role_description_ar'],
      roleCreatedAt: json['role_created_at'] != null
          ? DateTime.tryParse(json['role_created_at'])
          : null,
      roleUpdatedAt: json['role_updated_at'] != null
          ? DateTime.tryParse(json['role_updated_at'])
          : null,
      permissionId: json['permission_id'] ?? '',
      permissionKey: json['permission_key'] ?? '',
      permissionDescriptionEn: json['permission_description_en'] ?? '',
      permissionDescriptionAr: json['permission_description_ar'] ?? '',
      permissionCategoryEn: json['permission_category_en'] ?? '',
      permissionCategoryAr: json['permission_category_ar'] ?? '',
      permissionCreatedAt: json['permission_created_at'] != null
          ? DateTime.tryParse(json['permission_created_at'])
          : null,
      permissionUpdatedAt: json['permission_updated_at'] != null
          ? DateTime.tryParse(json['permission_updated_at'])
          : null,
      assignedBy: json['assigned_by'],
      assignedByEmail: json['assigned_by_email'],
      assignedByFullNameEn: json['assigned_by_full_name_en'],
      assignedByFullNameAr: json['assigned_by_full_name_ar'],
      assignedAt: json['assigned_at'] != null
          ? DateTime.tryParse(json['assigned_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name_en': roleNameEn,
      'role_name_ar': roleNameAr,
      'parent_role_id': parentRoleId,
      'role_description_en': roleDescriptionEn,
      'role_description_ar': roleDescriptionAr,
      'role_created_at': roleCreatedAt?.toIso8601String(),
      'role_updated_at': roleUpdatedAt?.toIso8601String(),
      'permission_id': permissionId,
      'permission_key': permissionKey,
      'permission_description_en': permissionDescriptionEn,
      'permission_description_ar': permissionDescriptionAr,
      'permission_category_en': permissionCategoryEn,
      'permission_category_ar': permissionCategoryAr,
      'permission_created_at': permissionCreatedAt?.toIso8601String(),
      'permission_updated_at': permissionUpdatedAt?.toIso8601String(),
      'assigned_by': assignedBy,
      'assigned_by_email': assignedByEmail,
      'assigned_by_full_name_en': assignedByFullNameEn,
      'assigned_by_full_name_ar': assignedByFullNameAr,
      'assigned_at': assignedAt?.toIso8601String(),
    };
  }

  RolePermissionViewModel copyWith({
    String? roleId,
    String? roleNameEn,
    String? roleNameAr,
    String? parentRoleId,
    String? roleDescriptionEn,
    String? roleDescriptionAr,
    DateTime? roleCreatedAt,
    DateTime? roleUpdatedAt,
    String? permissionId,
    String? permissionKey,
    String? permissionDescriptionEn,
    String? permissionDescriptionAr,
    String? permissionCategoryEn,
    String? permissionCategoryAr,
    DateTime? permissionCreatedAt,
    DateTime? permissionUpdatedAt,
    String? assignedBy,
    String? assignedByEmail,
    String? assignedByFullNameEn,
    String? assignedByFullNameAr,
    DateTime? assignedAt,
  }) {
    return RolePermissionViewModel(
      roleId: roleId ?? this.roleId,
      roleNameEn: roleNameEn ?? this.roleNameEn,
      roleNameAr: roleNameAr ?? this.roleNameAr,
      parentRoleId: parentRoleId ?? this.parentRoleId,
      roleDescriptionEn: roleDescriptionEn ?? this.roleDescriptionEn,
      roleDescriptionAr: roleDescriptionAr ?? this.roleDescriptionAr,
      roleCreatedAt: roleCreatedAt ?? this.roleCreatedAt,
      roleUpdatedAt: roleUpdatedAt ?? this.roleUpdatedAt,
      permissionId: permissionId ?? this.permissionId,
      permissionKey: permissionKey ?? this.permissionKey,
      permissionDescriptionEn:
          permissionDescriptionEn ?? this.permissionDescriptionEn,
      permissionDescriptionAr:
          permissionDescriptionAr ?? this.permissionDescriptionAr,
      permissionCategoryEn: permissionCategoryEn ?? this.permissionCategoryEn,
      permissionCategoryAr: permissionCategoryAr ?? this.permissionCategoryAr,
      permissionCreatedAt: permissionCreatedAt ?? this.permissionCreatedAt,
      permissionUpdatedAt: permissionUpdatedAt ?? this.permissionUpdatedAt,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedByEmail: assignedByEmail ?? this.assignedByEmail,
      assignedByFullNameEn: assignedByFullNameEn ?? this.assignedByFullNameEn,
      assignedByFullNameAr: assignedByFullNameAr ?? this.assignedByFullNameAr,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}
