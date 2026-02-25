import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitReports
    implements Usecase<ReportsViewerPageEntity, SubmitReportsParams> {
  final ReportsRepository reportsRepostory;
  SubmitReports(this.reportsRepostory);
  @override
  Future<Either<Failure, ReportsViewerPageEntity>> call(
      SubmitReportsParams params) async {
    return await reportsRepostory.submitReports(
      createdById: params.createdById,
      // status: params.status,
      // requestId: params.requestId,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class SubmitReportsParams {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  SubmitReportsParams({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}
