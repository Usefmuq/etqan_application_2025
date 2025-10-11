import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveAttendance
    implements Usecase<AttendanceViewerPageEntity, ApproveAttendanceParams> {
  final AttendanceRepository attendanceRepostory;
  ApproveAttendance(this.attendanceRepostory);
  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> call(
      ApproveAttendanceParams params) async {
    return await attendanceRepostory.approveAttendance(
      requestUnlockedFields: params.requestUnlockedFields,
      approvalSequenceModel: params.approvalSequenceModel,
      attendanceModel: params.attendanceModel,
    );
  }
}

class ApproveAttendanceParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;

  final AttendancesPageViewModel attendanceModel;

  ApproveAttendanceParams({
    required this.approvalSequenceModel,
    this.requestUnlockedFields,
    required this.attendanceModel,
  });
}
