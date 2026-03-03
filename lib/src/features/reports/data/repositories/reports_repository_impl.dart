import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource reportsRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const ReportsRepositoryImpl(
    this.reportsRemoteDataSource,
    this.permissionRemoteDataSource,
  );

  @override
  Future<Either<Failure, ReportsPageEntity>> getAllReportss() async {
    try {
      final reportssVeiw = await reportsRemoteDataSource.getAllReportssView();
      return right(ReportsPageEntity(
        reportssView: reportssVeiw,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportsViewerPageEntity>> fetchReportsViewerPage(
      {required String requestId}) async {
    try {
      final reportssVeiw =
          await reportsRemoteDataSource.getReportsViewByRequestId(requestId);
      return right(ReportsViewerPageEntity(
        reportssView: reportssVeiw,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
