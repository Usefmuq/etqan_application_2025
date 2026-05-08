part of 'services_manager_bloc.dart';

@immutable
sealed class ServicesManagerEvent {}

final class ServicesManagerSubmitEvent extends ServicesManagerEvent {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  ServicesManagerSubmitEvent({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class ServicesManagerUpdateEvent extends ServicesManagerEvent {
  final ServicesManagersPageViewModel servicesmanagerViewerPage;
  final String updatedBy;

  ServicesManagerUpdateEvent({
    required this.servicesmanagerViewerPage,
    required this.updatedBy,
  });
}

final class ServicesManagerApproveEvent extends ServicesManagerEvent {
  // final int approvalId;
  // final String approverUserId;
  // final String approvalStatus;
  // final int requestId;
  // final bool isActive;
  // final String approverComment;
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final ServicesManagersPageViewModel servicesmanagerModel;

  ServicesManagerApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.servicesmanagerModel,
  });
}

final class ServicesManagerGetAllServicesManagersEvent
    extends ServicesManagerEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  ServicesManagerGetAllServicesManagersEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
