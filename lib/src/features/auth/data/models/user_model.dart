import 'package:etqan_application_2025/src/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.firstNameEn,
    required super.lastNameEn,
    required super.firstNameAr,
    required super.lastNameAr,
    required super.phone,
    required super.departmentId,
    required super.positionId,
    required super.statusId,
    required super.reportTo,
    required super.languagePreference,
    required super.timezone,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstNameEn: map['first_name_en'] ?? '',
      lastNameEn: map['last_name_en'] ?? '',
      firstNameAr: map['first_name_ar'] ?? '',
      lastNameAr: map['last_name_ar'] ?? '',
      phone: map['phone'] ?? '',
      departmentId: map['department_id'] ?? '',
      positionId: map['position_id'] ?? '',
      statusId: map['status_id'] ?? '',
      reportTo: map['report_to'] ?? '',
      languagePreference: map['language_preference'] ?? '',
      timezone: map['timezone'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstNameEn,
    String? lastNameEn,
    String? firstNameAr,
    String? lastNameAr,
    String? phone,
    String? departmentId,
    String? positionId,
    String? statusId,
    String? reportTo,
    String? languagePreference,
    String? timezone,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstNameEn: firstNameEn ?? this.firstNameEn,
      lastNameEn: lastNameEn ?? this.lastNameEn,
      firstNameAr: firstNameAr ?? this.firstNameAr,
      lastNameAr: lastNameAr ?? this.lastNameAr,
      phone: phone ?? this.phone,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      statusId: statusId ?? this.statusId,
      reportTo: reportTo ?? this.reportTo,
      languagePreference: languagePreference ?? this.languagePreference,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
