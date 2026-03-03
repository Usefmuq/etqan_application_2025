import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchReportsPage
    implements Usecase<ReportsViewerPageEntity, FetchReportsPageParams> {
  final ReportsRepository reportsRepostory;
  FetchReportsPage(this.reportsRepostory);
  @override
  Future<Either<Failure, ReportsViewerPageEntity>> call(
      FetchReportsPageParams params) async {
    return await reportsRepostory.fetchReportsViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchReportsPageParams {
  final String requestId;

  FetchReportsPageParams({
    required this.requestId,
  });
}
