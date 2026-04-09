import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ReportsRepository {
  Future<Either<Failure, ReportsPageEntity>> getAllReportss();
  Future<Either<Failure, ReportsViewerPageEntity>> fetchReportsViewerPage({
    required String requestId,
  });
  Future<Either<Failure, ReportsViewerPageEntity>> fetchAttendanceReport({
    required String selectedEmployeeId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
