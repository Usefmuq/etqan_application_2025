part of 'attendance_bloc.dart';

@immutable
sealed class AttendanceEvent {}

final class AttendanceSubmitEvent extends AttendanceEvent {
  final AttendanceSessionModel attendance;

  AttendanceSubmitEvent({
    required this.attendance,
  });
}

final class AttendanceRegularizationSubmitEvent extends AttendanceEvent {
  final AttendanceRegularizationModel attendance;

  AttendanceRegularizationSubmitEvent({
    required this.attendance,
  });
}

final class AttendanceUpdateEvent extends AttendanceEvent {
  final AttendancesPageViewModel attendanceViewerPage;
  final String updatedBy;

  AttendanceUpdateEvent({
    required this.attendanceViewerPage,
    required this.updatedBy,
  });
}

final class AttendanceRegularizationUpdateEvent extends AttendanceEvent {
  final AttendanceRegularizationViewModel attendanceRegularizationViewerPage;
  final String updatedBy;

  AttendanceRegularizationUpdateEvent({
    required this.attendanceRegularizationViewerPage,
    required this.updatedBy,
  });
}

final class AttendanceApproveEvent extends AttendanceEvent {
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final AttendancesPageViewModel attendanceModel;

  AttendanceApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.attendanceModel,
  });
}

final class AttendanceRegularizationApproveEvent extends AttendanceEvent {
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final AttendanceRegularizationViewModel attendanceregularizationModel;

  AttendanceRegularizationApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.attendanceregularizationModel,
  });
}

final class AttendanceRegularizationGetAllAttendancesEvent
    extends AttendanceEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  AttendanceRegularizationGetAllAttendancesEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
