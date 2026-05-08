import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/datasources/services_manager_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/repositories/services_manager_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class ServicesManagerRepositoryImpl implements ServicesManagerRepository {
  final ServicesManagerRemoteDataSource servicesmanagerRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const ServicesManagerRepositoryImpl(
    this.servicesmanagerRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      submitServicesManager({
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
        serviceId: ServicesConstants.servicesManagerServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      ServicesManagerModel servicesmanagerModel = ServicesManagerModel(
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
      final insertedServicesManager = await servicesmanagerRemoteDataSource
          .submitServicesManager(servicesmanagerModel, requestMasterModel);
      return right(insertedServicesManager);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      updateServicesManager({
    required ServicesManagersPageViewModel servicesmanagerViewerPage,
    required String updatedBy,
  }) async {
    try {
      final updatedServicesManager =
          await servicesmanagerRemoteDataSource.updateServicesManager(
        servicesmanagerViewerPage,
        updatedBy,
      );
      return right(updatedServicesManager);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      approveServicesManager({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required ServicesManagersPageViewModel servicesmanagerModel,
  }) async {
    try {
      final approvedServicesManager =
          await servicesmanagerRemoteDataSource.approveServicesManager(
        approvalSequenceModel,
        requestUnlockedFields,
        servicesmanagerModel,
      );
      return right(approvedServicesManager);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServicesManagerPageEntity>> getAllServicesManagers({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  }) async {
    try {
      final servicesmanagersVeiw =
          await servicesmanagerRemoteDataSource.getAllServicesManagersView(
        user.id,
        departmentId,
        isManagerExpanded,
        isDepartmentManagerExpanded,
        isViewAll,
      );
      final approvalsView =
          await servicesmanagerRemoteDataSource.getAllApprovalsView();
      return right(ServicesManagerPageEntity(
        servicesmanagersView: servicesmanagersVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      fetchServicesManagerViewerPage({required int requestId}) async {
    try {
      final servicesmanagersVeiw = await servicesmanagerRemoteDataSource
          .getServicesManagerViewByRequestId(requestId);
      final approvalsView = await servicesmanagerRemoteDataSource
          .getApprovalViewByRequestId(requestId);
      return right(ServicesManagerViewerPageEntity(
        servicesmanagersView: servicesmanagersVeiw,
        approval: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
