import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateAttendanceRegularization
    implements
        Usecase<AttendanceRegularizationViewerPageEntity,
            UpdateAttendanceRegularizationParams> {
  final AttendanceRepository attendanceregularizationRepostory;
  UpdateAttendanceRegularization(this.attendanceregularizationRepostory);
  @override
  Future<Either<Failure, AttendanceRegularizationViewerPageEntity>> call(
      UpdateAttendanceRegularizationParams params) async {
    return await attendanceregularizationRepostory
        .updateAttendanceRegularization(
      attendanceViewerPage: params.attendanceregularizationViewerPage,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateAttendanceRegularizationParams {
  final AttendanceRegularizationViewModel attendanceregularizationViewerPage;
  final String updatedBy;

  UpdateAttendanceRegularizationParams({
    required this.attendanceregularizationViewerPage,
    required this.updatedBy,
  });
}
