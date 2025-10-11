part of 'attendance_bloc.dart';

@immutable
sealed class AttendanceState {}

final class AttendanceInitial extends AttendanceState {}

final class AttendanceLoading extends AttendanceState {}

final class AttendanceFailure extends AttendanceState {
  final String error;
  AttendanceFailure(this.error);
}

final class AttendanceSubmitSuccess extends AttendanceState {}

final class AttendanceUpdateSuccess extends AttendanceState {
  final AttendanceViewerPageEntity attendanceViewerPageEntity;
  AttendanceUpdateSuccess(this.attendanceViewerPageEntity);
}

final class AttendanceApproveSuccess extends AttendanceState {
  final AttendanceViewerPageEntity attendanceViewerPageEntity;
  AttendanceApproveSuccess(this.attendanceViewerPageEntity);
}

final class AttendanceShowAllSuccess extends AttendanceState {
  final AttendancePageEntity attendancePage;
  AttendanceShowAllSuccess(this.attendancePage);
}
