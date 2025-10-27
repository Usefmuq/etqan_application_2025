import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/usecases/approve_attendance.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/usecases/get_all_attendances.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/usecases/submit_attendance.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/usecases/update_attendance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final SubmitAttendance _submitAttendance;
  final UpdateAttendance _updateAttendance;
  final ApproveAttendance _approveAttendance;
  final GetAllAttendances _getAllAttendances;
  AttendanceBloc({
    required SubmitAttendance submitAttendance,
    required UpdateAttendance updateAttendance,
    required ApproveAttendance approveAttendance,
    required GetAllAttendances getAllAttendances,
  })  : _submitAttendance = submitAttendance,
        _updateAttendance = updateAttendance,
        _approveAttendance = approveAttendance,
        _getAllAttendances = getAllAttendances,
        super(AttendanceInitial()) {
    on<AttendanceEvent>((event, emit) => emit(AttendanceLoading()));
    on<AttendanceSubmitEvent>(_onAttendanceSubmitEvent);
    on<AttendanceUpdateEvent>(_onAttendanceUpdateEvent);
    on<AttendanceApproveEvent>(_onAttendanceApproveEvent);
    on<AttendanceGetAllAttendancesEvent>(_onAttendanceGetAllAttendancesEvent);
  }

  void _onAttendanceSubmitEvent(
    AttendanceSubmitEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final response = await _submitAttendance(SubmitAttendanceParams(
      attendance: event.attendance,
    ));
    response.fold(
      (failure) => emit(AttendanceFailure(failure.message)),
      (attendance) {
        emit(AttendanceSubmitSuccess());
      },
    );
  }

  void _onAttendanceUpdateEvent(
    AttendanceUpdateEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final response = await _updateAttendance(UpdateAttendanceParams(
      attendanceViewerPage: event.attendanceViewerPage,
      updatedBy: event.updatedBy,
    ));
    response.fold(
      (failure) => emit(AttendanceFailure(failure.message)),
      (attendance) {
        emit(AttendanceUpdateSuccess(attendance));
      },
    );
  }

  void _onAttendanceApproveEvent(
    AttendanceApproveEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final response = await _approveAttendance(ApproveAttendanceParams(
      approvalSequenceModel: event.approvalSequence,
      requestUnlockedFields: event.requestUnlockedFields,
      attendanceModel: event.attendanceModel,
    ));
    response.fold(
      (failure) => emit(AttendanceFailure(failure.message)),
      (attendance) {
        emit(AttendanceApproveSuccess(attendance));
      },
    );
  }

  void _onAttendanceGetAllAttendancesEvent(
    AttendanceGetAllAttendancesEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final response = await _getAllAttendances(GetAllAttendancesParams(
      user: event.user,
      departmentId: event.departmentId,
      isManagerExpanded: event.isManagerExpanded,
      isDepartmentManagerExpanded: event.isDepartmentManagerExpanded,
      isViewAll: event.isViewAll,
    ));
    response.fold(
      (failure) => emit(AttendanceFailure(failure.message)),
      (attendances) {
        emit(AttendanceShowAllSuccess(attendances));
      },
    );
  }
}
