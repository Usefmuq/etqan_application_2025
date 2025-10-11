import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AttendanceRepository {
  Future<Either<Failure, AttendanceViewerPageEntity>> submitAttendance({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
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
  Future<Either<Failure, AttendancePageEntity>> getAllAttendances({
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
}
