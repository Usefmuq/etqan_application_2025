class Departments {
  final String id;
  final String nameEn;
  final String nameAr;
  final String code;
  final String departmentTypeId;
  final String? parentDepartmentId;
  final String? locationEn;
  final String? locationAr;
  final String? managerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive; // if you decide to add it later

  Departments({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.code,
    required this.departmentTypeId,
    this.parentDepartmentId,
    this.locationEn,
    this.locationAr,
    this.managerId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true, // optional default
  });

  factory Departments.fromJson(Map<String, dynamic> json) {
    return Departments(
      id: json['department_id'],
      nameEn: json['department_name_en'],
      nameAr: json['department_name_ar'],
      code: json['department_code'],
      departmentTypeId: json['department_type_id'],
      parentDepartmentId: json['parent_department_id'],
      locationEn: json['location_en'],
      locationAr: json['location_ar'],
      managerId: json['manager_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_id': id,
      'department_name_en': nameEn,
      'department_name_ar': nameAr,
      'department_code': code,
      'department_type_id': departmentTypeId,
      'parent_department_id': parentDepartmentId,
      'location_en': locationEn,
      'location_ar': locationAr,
      'manager_id': managerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
