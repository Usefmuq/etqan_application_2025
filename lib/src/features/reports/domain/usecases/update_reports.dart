// import 'package:etqan_application_2025/src/core/error/failure.dart';
// import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
// import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
// import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
// import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
// import 'package:fpdart/fpdart.dart';

// class UpdateReports
//     implements Usecase<ReportsViewerPageEntity, UpdateReportsParams> {
//   final ReportsRepository reportsRepostory;
//   UpdateReports(this.reportsRepostory);
//   @override
//   Future<Either<Failure, ReportsViewerPageEntity>> call(
//       UpdateReportsParams params) async {
//     return await reportsRepostory.updateReports(
//       reportsViewerPage: params.reportsViewerPage,
//       updatedBy: params.updatedBy,
//     );
//   }
// }

// class UpdateReportsParams {
//   final ReportssPageViewModel reportsViewerPage;
//   final String updatedBy;

//   UpdateReportsParams({
//     required this.reportsViewerPage,
//     required this.updatedBy,
//   });
// }
