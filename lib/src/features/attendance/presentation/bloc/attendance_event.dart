part of 'attendance_bloc.dart';

@immutable
sealed class AttendanceEvent {}

final class AttendanceSubmitEvent extends AttendanceEvent {
  final AttendanceSessionModel attendance;

  AttendanceSubmitEvent({
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

final class AttendanceApproveEvent extends AttendanceEvent {
  // final int approvalId;
  // final String approverUserId;
  // final String approvalStatus;
  // final int requestId;
  // final bool isActive;
  // final String approverComment;
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final AttendancesPageViewModel attendanceModel;

  AttendanceApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.attendanceModel,
  });
}

final class AttendanceGetAllAttendancesEvent extends AttendanceEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  AttendanceGetAllAttendancesEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
