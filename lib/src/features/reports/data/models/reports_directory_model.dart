import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_directory.dart';

class ReportsDirectoryModel extends ReportsDirectory {
  const ReportsDirectoryModel({
    required super.id,
    required super.reportKey,
    required super.titleEn,
    required super.titleAr,
    super.descriptionEn,
    super.descriptionAr,
    required super.viewName,
    required super.isActive,
    required super.createdAt,
  });

  factory ReportsDirectoryModel.fromJson(Map<String, dynamic> json) {
    return ReportsDirectoryModel(
      id: json['id'] as String,
      reportKey: json['report_key'] as String,
      titleEn: json['title_en'] as String,
      titleAr: json['title_ar'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      viewName: json['view_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_key': reportKey,
      'title_en': titleEn,
      'title_ar': titleAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'view_name': viewName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReportsDirectoryModel copyWith({
    String? id,
    String? reportKey,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    String? viewName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ReportsDirectoryModel(
      id: id ?? this.id,
      reportKey: reportKey ?? this.reportKey,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      viewName: viewName ?? this.viewName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
