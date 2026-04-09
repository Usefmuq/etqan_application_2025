import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchAttendanceReport
    implements Usecase<ReportsViewerPageEntity, FetchAttendanceParams> {
  final ReportsRepository reportsRepostory;
  FetchAttendanceReport(this.reportsRepostory);
  @override
  Future<Either<Failure, ReportsViewerPageEntity>> call(
      FetchAttendanceParams params) async {
    return await reportsRepostory.fetchAttendanceReport(
      selectedEmployeeId: params.selectedEmployeeId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FetchAttendanceParams {
  final String selectedEmployeeId;
  final DateTime startDate;
  final DateTime endDate;

  FetchAttendanceParams({
    required this.selectedEmployeeId,
    required this.startDate,
    required this.endDate,
  });
}
