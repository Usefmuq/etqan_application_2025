import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllReportss
    implements Usecase<ReportsPageEntity, GetAllReportssParams> {
  final ReportsRepository reportsRepostory;
  GetAllReportss(this.reportsRepostory);
  @override
  Future<Either<Failure, ReportsPageEntity>> call(
      GetAllReportssParams params) async {
    return await reportsRepostory.getAllReportss();
  }
}

class GetAllReportssParams {
  GetAllReportssParams();
}
