import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateAttendance
    implements Usecase<AttendanceViewerPageEntity, UpdateAttendanceParams> {
  final AttendanceRepository attendanceRepostory;
  UpdateAttendance(this.attendanceRepostory);
  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> call(
      UpdateAttendanceParams params) async {
    return await attendanceRepostory.updateAttendance(
      attendanceViewerPage: params.attendanceViewerPage,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateAttendanceParams {
  final AttendancesPageViewModel attendanceViewerPage;
  final String updatedBy;

  UpdateAttendanceParams({
    required this.attendanceViewerPage,
    required this.updatedBy,
  });
}
