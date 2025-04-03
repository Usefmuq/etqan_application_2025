// onboardings_page_view_model.dart
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboardings_page_view.dart';

class OnboardingsPageViewModel extends OnboardingsPageView {
  OnboardingsPageViewModel({
    super.onboardingId,
    super.title,
    super.content,
    super.status,
    super.isActive,
    super.topics,
    super.onboardingUpdatedAt,
    super.createdById,
    super.fullNameEn,
    super.fullNameAr,
    super.email,
    super.phone,
    super.departmentId,
    super.departmentNameEn,
    super.departmentNameAr,
    super.positionId,
    super.positionNameEn,
    super.positionNameAr,
    super.reportTo,
    super.reportToNameEn,
    super.reportToNameAr,
    super.requestId,
    super.serviceId,
    super.serviceNameEn,
    super.serviceNameAr,
    super.requestStatusId,
    super.requestStatusKey,
    super.requestStatusEn,
    super.requestStatusAr,
    super.priorityId,
    super.priorityKey,
    super.priorityEn,
    super.priorityAr,
    super.requestDetails,
    super.requestCreatedAt,
    super.requestUpdatedAt,
    super.requestApprovedAt,
    super.requestIsActive,
    super.numberOfManagerApprovalsNeeded,
    super.numberOfApprovalsNeeded,
    super.numberOfApprovalsDone,
    super.numberOfApprovalsPending,
  });

  factory OnboardingsPageViewModel.fromJson(Map<String, dynamic> json) {
    return OnboardingsPageViewModel(
      onboardingId: json['id'],
      title: json['title'],
      content: json['content'],
      status: json['status'],
      isActive: json['is_active'],
      topics: json['topics'] != null ? List<String>.from(json['topics']) : null,
      onboardingUpdatedAt: json['onboarding_updated_at'] != null
          ? DateTime.tryParse(json['onboarding_updated_at'])
          : null,
      createdById: json['created_by_id'],
      fullNameEn: json['full_name_en'],
      fullNameAr: json['full_name_ar'],
      email: json['email'],
      phone: json['phone'],
      departmentId: json['department_id'],
      departmentNameEn: json['department_name_en'],
      departmentNameAr: json['department_name_ar'],
      positionId: json['position_id'],
      positionNameEn: json['position_name_en'],
      positionNameAr: json['position_name_ar'],
      reportTo: json['report_to'],
      reportToNameEn: json['report_to_name_en'],
      reportToNameAr: json['report_to_name_ar'],
      requestId: json['request_id'],
      serviceId: json['service_id'],
      serviceNameEn: json['service_name_en'],
      serviceNameAr: json['service_name_ar'],
      requestStatusId: json['request_status_id'],
      requestStatusKey: json['request_status_key'],
      requestStatusEn: json['request_status_en'],
      requestStatusAr: json['request_status_ar'],
      priorityId: json['priority_id'],
      priorityKey: json['priority_key'],
      priorityEn: json['priority_en'],
      priorityAr: json['priority_ar'],
      requestDetails: json['request_details'],
      requestCreatedAt: json['request_created_at'] != null
          ? DateTime.tryParse(json['request_created_at'])
          : null,
      requestUpdatedAt: json['request_updated_at'] != null
          ? DateTime.tryParse(json['request_updated_at'])
          : null,
      requestApprovedAt: json['request_approved_at'] != null
          ? DateTime.tryParse(json['request_approved_at'])
          : null,
      requestIsActive: json['request_is_active'],
      numberOfManagerApprovalsNeeded:
          json['number_of_manager_approvals_needed'],
      numberOfApprovalsNeeded: json['number_of_approvals_needed'],
      numberOfApprovalsDone: json['number_of_approvals_done'],
      numberOfApprovalsPending: json['number_of_approvals_pending'],
    );
  }

  Onboarding? toOnboarding() {
    return Onboarding(
      id: onboardingId ?? "",
      createdById: createdById ?? "",
      updatedAt: onboardingUpdatedAt ?? DateTime.now(),
      status: status ?? "",
      requestId: requestId ?? 0,
      isActive: isActive ?? true,
      title: title ?? "",
      content: content ?? "",
      topics: topics ?? [],
    );
  }
}
