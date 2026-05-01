import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AttendanceRepository {
  Future<Either<Failure, AttendanceViewerPageEntity>> submitAttendance({
    required AttendanceSessionModel attendance,
  });
  Future<Either<Failure, AttendanceRegularizationViewerPageEntity>>
      submitAttendanceRegularization({
    required AttendanceRegularizationModel attendance,
  });
  Future<Either<Failure, AttendanceViewerPageEntity>> updateAttendance({
    required AttendancesPageViewModel attendanceViewerPage,
    required String updatedBy,
  });
  Future<Either<Failure, AttendanceViewerPageEntity>> approveAttendance({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required AttendancesPageViewModel attendanceModel,
  });
  Future<Either<Failure, AttendanceRegularizationPageEntity>>
      getAllAttendances({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  });
  Future<Either<Failure, AttendanceViewerPageEntity>>
      fetchAttendanceViewerPage({
    required int requestId,
  });
  Future<Either<Failure, AttendanceRegularizationViewerPageEntity>>
      fetchAttendanceRegularizationViewerPage({
    required int requestId,
  });
}
