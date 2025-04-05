class Positions {
  final String id;
  final String nameEn;
  final String nameAr;
  final String departmentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool
      isActive; // Optional: if you plan to add soft deletes or active/inactive state

  Positions({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.departmentId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Positions.fromJson(Map<String, dynamic> json) {
    return Positions(
      id: json['position_id'],
      nameEn: json['position_name_en'],
      nameAr: json['position_name_ar'],
      departmentId: json['department_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position_id': id,
      'position_name_en': nameEn,
      'position_name_ar': nameAr,
      'department_id': departmentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  Positions copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? departmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Positions(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      departmentId: departmentId ?? this.departmentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
