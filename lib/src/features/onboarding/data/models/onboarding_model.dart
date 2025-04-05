// onboarding_model.dart
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding.dart';

class OnboardingModel extends Onboarding {
  OnboardingModel({
    super.onboardingId,
    required super.firstNameEn,
    required super.lastNameEn,
    super.firstNameAr,
    super.lastNameAr,
    required super.email,
    super.phone,
    super.departmentId,
    super.positionId,
    super.reportTo,
    required super.startDate,
    super.status,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.isActive,
    super.requestId,
    super.notes,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      onboardingId: json['onboarding_id'],
      firstNameEn: json['first_name_en'],
      lastNameEn: json['last_name_en'],
      firstNameAr: json['first_name_ar'],
      lastNameAr: json['last_name_ar'],
      email: json['email'],
      phone: json['phone'],
      departmentId: json['department_id'],
      positionId: json['position_id'],
      reportTo: json['report_to'],
      startDate: DateTime.parse(json['start_date']),
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isActive: json['is_active'] ?? true,
      requestId: json['request_id'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'onboarding_id': onboardingId,
      'first_name_en': firstNameEn,
      'last_name_en': lastNameEn,
      'first_name_ar': firstNameAr,
      'last_name_ar': lastNameAr,
      'email': email,
      'phone': phone,
      'department_id': departmentId,
      'position_id': positionId,
      'report_to': reportTo,
      'start_date': startDate.toIso8601String(),
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'request_id': requestId,
      'notes': notes,
    };
  }

  Onboarding toEntity() {
    return Onboarding(
      onboardingId: onboardingId,
      firstNameEn: firstNameEn,
      lastNameEn: lastNameEn,
      firstNameAr: firstNameAr,
      lastNameAr: lastNameAr,
      email: email,
      phone: phone,
      departmentId: departmentId,
      positionId: positionId,
      reportTo: reportTo,
      startDate: startDate,
      status: status,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      requestId: requestId,
      notes: notes,
    );
  }

  Map<String, dynamic> toTableRow() {
    return {
      'Full Name': '$firstNameEn $lastNameEn',
      'Email': email,
      'Phone': phone ?? 'N/A',
      'Department': departmentId ?? 'N/A',
      'Position': positionId ?? 'N/A',
      'Manager': reportTo ?? 'N/A',
      'Start Date': startDate.toLocal().toString(),
      'Status': status ?? 'N/A',
      'Created By': createdBy ?? 'N/A',
      'Active Status': isActive ? 'Active' : 'Inactive',
    };
  }

  OnboardingModel copyWith({
    int? onboardingId,
    String? firstNameEn,
    String? lastNameEn,
    String? firstNameAr,
    String? lastNameAr,
    String? email,
    String? phone,
    String? departmentId,
    String? positionId,
    String? reportTo,
    DateTime? startDate,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? requestId,
    String? notes,
  }) {
    return OnboardingModel(
      onboardingId: onboardingId ?? this.onboardingId,
      firstNameEn: firstNameEn ?? this.firstNameEn,
      lastNameEn: lastNameEn ?? this.lastNameEn,
      firstNameAr: firstNameAr ?? this.firstNameAr,
      lastNameAr: lastNameAr ?? this.lastNameAr,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      reportTo: reportTo ?? this.reportTo,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      requestId: requestId ?? this.requestId,
      notes: notes ?? this.notes,
    );
  }
}
