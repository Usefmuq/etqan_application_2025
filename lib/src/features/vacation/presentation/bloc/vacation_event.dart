part of 'vacation_bloc.dart';

@immutable
sealed class VacationEvent {}

final class VacationSubmitEvent extends VacationEvent {
  final String createdById;
  final String vacationTypeId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final double daysCount;

  VacationSubmitEvent({
    required this.createdById,
    required this.vacationTypeId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
  });
}

final class VacationUpdateEvent extends VacationEvent {
  final VacationsPageViewModel vacationViewerPage;
  final String updatedBy;

  VacationUpdateEvent({
    required this.vacationViewerPage,
    required this.updatedBy,
  });
}

final class VacationApproveEvent extends VacationEvent {
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final VacationsPageViewModel vacationModel;

  VacationApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.vacationModel,
  });
}

final class VacationGetAllVacationsEvent extends VacationEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  VacationGetAllVacationsEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
