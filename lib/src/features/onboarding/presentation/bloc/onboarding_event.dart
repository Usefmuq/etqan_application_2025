part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingEvent {}

final class OnboardingSubmitEvent extends OnboardingEvent {
  final String createdBy;
  final String firstNameEn;
  final String lastNameEn;
  final String firstNameAr;
  final String lastNameAr;
  final String email;
  final String phone;
  final String departmentId;
  final String positionId;
  final String reportTo;
  final DateTime startDate;
  final String notes;

  OnboardingSubmitEvent({
    required this.createdBy,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.firstNameAr,
    required this.lastNameAr,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.positionId,
    required this.reportTo,
    required this.startDate,
    required this.notes,
  });
}

final class OnboardingUpdateEvent extends OnboardingEvent {
  final OnboardingsPageViewModel onboardingsPageViewModel;

  OnboardingUpdateEvent({
    required this.onboardingsPageViewModel,
  });
}

final class OnboardingApproveEvent extends OnboardingEvent {
  // final int approvalId;
  // final String approverUserId;
  // final String approvalStatus;
  // final int requestId;
  // final bool isActive;
  // final String approverComment;
  final ApprovalSequenceViewModel approvalSequence;
  final OnboardingsPageViewModel onboardingModel;

  OnboardingApproveEvent({
    required this.approvalSequence,
    required this.onboardingModel,
  });
}

final class OnboardingGetAllOnboardingsEvent extends OnboardingEvent {}
