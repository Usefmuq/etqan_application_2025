import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ReportsRepository {
  Future<Either<Failure, ReportsViewerPageEntity>> submitReports({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, ReportsViewerPageEntity>> updateReports({
    required ReportssPageViewModel reportsViewerPage,
    required String updatedBy,
  });
  Future<Either<Failure, ReportsViewerPageEntity>> approveReports({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required ReportssPageViewModel reportsModel,
  });
  Future<Either<Failure, ReportsPageEntity>> getAllReportss({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  });
  Future<Either<Failure, ReportsViewerPageEntity>> fetchReportsViewerPage({
    required int requestId,
  });
}
