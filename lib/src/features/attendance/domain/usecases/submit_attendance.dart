import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitAttendance
    implements Usecase<AttendanceViewerPageEntity, SubmitAttendanceParams> {
  final AttendanceRepository attendanceRepostory;
  SubmitAttendance(this.attendanceRepostory);
  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> call(
      SubmitAttendanceParams params) async {
    return await attendanceRepostory.submitAttendance(
      attendance: params.attendance,
    );
  }
}

class SubmitAttendanceParams {
  final AttendanceSessionModel attendance;

  SubmitAttendanceParams({
    required this.attendance,
  });
}
