import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitAttendanceRegularization
    implements
        Usecase<AttendanceRegularizationViewerPageEntity,
            SubmitAttendanceRegularizationParams> {
  final AttendanceRepository attendanceRepostory;
  SubmitAttendanceRegularization(this.attendanceRepostory);
  @override
  Future<Either<Failure, AttendanceRegularizationViewerPageEntity>> call(
      SubmitAttendanceRegularizationParams params) async {
    return await attendanceRepostory.submitAttendanceRegularization(
      attendance: params.attendance,
    );
  }
}

class SubmitAttendanceRegularizationParams {
  final AttendanceRegularizationModel attendance;

  SubmitAttendanceRegularizationParams({
    required this.attendance,
  });
}
