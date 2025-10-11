import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
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
      createdById: params.createdById,
      // status: params.status,
      // requestId: params.requestId,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class SubmitAttendanceParams {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  SubmitAttendanceParams({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}
