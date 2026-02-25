import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveReports
    implements Usecase<ReportsViewerPageEntity, ApproveReportsParams> {
  final ReportsRepository reportsRepostory;
  ApproveReports(this.reportsRepostory);
  @override
  Future<Either<Failure, ReportsViewerPageEntity>> call(
      ApproveReportsParams params) async {
    return await reportsRepostory.approveReports(
      requestUnlockedFields: params.requestUnlockedFields,
      approvalSequenceModel: params.approvalSequenceModel,
      reportsModel: params.reportsModel,
    );
  }
}

class ApproveReportsParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;

  final ReportssPageViewModel reportsModel;

  ApproveReportsParams({
    required this.approvalSequenceModel,
    this.requestUnlockedFields,
    required this.reportsModel,
  });
}
