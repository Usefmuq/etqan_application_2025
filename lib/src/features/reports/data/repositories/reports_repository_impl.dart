import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/repositories/reports_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource reportsRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const ReportsRepositoryImpl(
    this.reportsRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, ReportsViewerPageEntity>> submitReports({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
  }) async {
    try {
      RequestMasterModel requestMasterModel = RequestMasterModel(
        // requestId: 0,
        userId: createdById,
        serviceId: ServicesConstants.reportsServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      ReportsModel reportsModel = ReportsModel(
        id: Uuid().v1(),
        createdById: createdById,
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        status: LookupConstants.requestStatusPending,
        requestId: -1,
        isActive: true,
        title: title,
        content: content,
        topics: topics,
      );
      final insertedReports = await reportsRemoteDataSource.submitReports(
          reportsModel, requestMasterModel);
      return right(insertedReports);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportsViewerPageEntity>> updateReports({
    required ReportssPageViewModel reportsViewerPage,
    required String updatedBy,
  }) async {
    try {
      final updatedReports = await reportsRemoteDataSource.updateReports(
        reportsViewerPage,
        updatedBy,
      );
      return right(updatedReports);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportsViewerPageEntity>> approveReports({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required ReportssPageViewModel reportsModel,
  }) async {
    try {
      final approvedReports = await reportsRemoteDataSource.approveReports(
        approvalSequenceModel,
        requestUnlockedFields,
        reportsModel,
      );
      return right(approvedReports);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportsPageEntity>> getAllReportss({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  }) async {
    try {
      final reportssVeiw = await reportsRemoteDataSource.getAllReportssView(
        user.id,
        departmentId,
        isManagerExpanded,
        isDepartmentManagerExpanded,
        isViewAll,
      );
      final approvalsView = await reportsRemoteDataSource.getAllApprovalsView();
      return right(ReportsPageEntity(
        reportssView: reportssVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportsViewerPageEntity>> fetchReportsViewerPage(
      {required int requestId}) async {
    try {
      final reportssVeiw =
          await reportsRemoteDataSource.getReportsViewByRequestId(requestId);
      final approvalsView =
          await reportsRemoteDataSource.getApprovalViewByRequestId(requestId);
      return right(ReportsViewerPageEntity(
        reportssView: reportssVeiw,
        approval: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
