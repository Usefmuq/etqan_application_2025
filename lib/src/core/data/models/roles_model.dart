// roles.dart

class Roles {
  final String roleId;
  final String roleNameEn;
  final String roleNameAr;
  final String? parentRoleId;
  final String? descriptionEn;
  final String? descriptionAr;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Roles({
    required this.roleId,
    required this.roleNameEn,
    required this.roleNameAr,
    this.parentRoleId,
    this.descriptionEn,
    this.descriptionAr,
    this.createdAt,
    this.updatedAt,
  });
}

class RolesModel extends Roles {
  RolesModel({
    required super.roleId,
    required super.roleNameEn,
    required super.roleNameAr,
    super.parentRoleId,
    super.descriptionEn,
    super.descriptionAr,
    super.createdAt,
    super.updatedAt,
  });

  factory RolesModel.fromJson(Map<String, dynamic> json) {
    return RolesModel(
      roleId: json['role_id'] ?? '',
      roleNameEn: json['role_name_en'] ?? '',
      roleNameAr: json['role_name_ar'] ?? '',
      parentRoleId: json['parent_role_id'],
      descriptionEn: json['description_en'],
      descriptionAr: json['description_ar'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name_en': roleNameEn,
      'role_name_ar': roleNameAr,
      'parent_role_id': parentRoleId,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RolesModel copyWith({
    String? roleId,
    String? roleNameEn,
    String? roleNameAr,
    String? parentRoleId,
    String? descriptionEn,
    String? descriptionAr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RolesModel(
      roleId: roleId ?? this.roleId,
      roleNameEn: roleNameEn ?? this.roleNameEn,
      roleNameAr: roleNameAr ?? this.roleNameAr,
      parentRoleId: parentRoleId ?? this.parentRoleId,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
