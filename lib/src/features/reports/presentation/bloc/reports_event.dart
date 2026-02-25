part of 'reports_bloc.dart';

@immutable
sealed class ReportsEvent {}

final class ReportsSubmitEvent extends ReportsEvent {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  ReportsSubmitEvent({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class ReportsUpdateEvent extends ReportsEvent {
  final ReportssPageViewModel reportsViewerPage;
  final String updatedBy;

  ReportsUpdateEvent({
    required this.reportsViewerPage,
    required this.updatedBy,
  });
}

final class ReportsApproveEvent extends ReportsEvent {
  // final int approvalId;
  // final String approverUserId;
  // final String approvalStatus;
  // final int requestId;
  // final bool isActive;
  // final String approverComment;
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final ReportssPageViewModel reportsModel;

  ReportsApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.reportsModel,
  });
}

final class ReportsGetAllReportssEvent extends ReportsEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  ReportsGetAllReportssEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
