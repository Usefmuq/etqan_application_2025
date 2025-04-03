part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingEvent {}

final class OnboardingSubmitEvent extends OnboardingEvent {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  OnboardingSubmitEvent({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class OnboardingUpdateEvent extends OnboardingEvent {
  final String id;
  final String createdById;
  final String status;
  final int requestId;
  final bool isActive;
  final String title;
  final String content;
  final List<String> topics;

  OnboardingUpdateEvent({
    required this.id,
    required this.createdById,
    required this.status,
    required this.requestId,
    required this.isActive,
    required this.title,
    required this.content,
    required this.topics,
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
