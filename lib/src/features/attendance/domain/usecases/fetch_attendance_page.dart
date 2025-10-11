import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchAttendancePage
    implements Usecase<AttendanceViewerPageEntity, FetchAttendancePageParams> {
  final AttendanceRepository attendanceRepostory;
  FetchAttendancePage(this.attendanceRepostory);
  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> call(
      FetchAttendancePageParams params) async {
    return await attendanceRepostory.fetchAttendanceViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchAttendancePageParams {
  final int requestId;

  FetchAttendancePageParams({
    required this.requestId,
  });
}
