import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchAttendanceRegularizationPage
    implements
        Usecase<AttendanceRegularizationViewerPageEntity,
            FetchAttendanceRegularizationPageParams> {
  final AttendanceRepository attendanceregularizationRepostory;
  FetchAttendanceRegularizationPage(this.attendanceregularizationRepostory);
  @override
  Future<Either<Failure, AttendanceRegularizationViewerPageEntity>> call(
      FetchAttendanceRegularizationPageParams params) async {
    return await attendanceregularizationRepostory
        .fetchAttendanceRegularizationViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchAttendanceRegularizationPageParams {
  final int requestId;

  FetchAttendanceRegularizationPageParams({
    required this.requestId,
  });
}
