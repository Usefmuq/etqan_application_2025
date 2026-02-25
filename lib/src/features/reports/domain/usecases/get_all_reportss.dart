import 'package:etqan_application_2025/src/core/common/entities/user.dart';
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
    return await reportsRepostory.getAllReportss(
      user: params.user,
      departmentId: params.departmentId,
      isManagerExpanded: params.isManagerExpanded,
      isDepartmentManagerExpanded: params.isDepartmentManagerExpanded,
      isViewAll: params.isViewAll,
    );
  }
}

class GetAllReportssParams {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;

  GetAllReportssParams({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
