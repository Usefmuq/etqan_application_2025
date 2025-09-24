import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/datasources/users_manager_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/repositories/users_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class UsersManagerRepositoryImpl implements UsersManagerRepository {
  final UsersManagerRemoteDataSource usersManagerRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const UsersManagerRepositoryImpl(
    this.usersManagerRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> submitUsersManager({
    required String createdById,
    required String userId,
    required String roleId,
    required DateTime startAt,
    required DateTime? endAt,
    required String action,
    required String notes,
    required String departmentId,
    required bool appliesToAllDepartments,
  }) async {
    try {
      RequestMasterModel requestMasterModel = RequestMasterModel(
        // requestId: 0,
        userId: createdById,
        serviceId: ServicesConstants.usersManagerServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      UsersManagerModel usersManagerModel = UsersManagerModel(
        createdById: createdById,
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        requestId: -1,
        userId: userId,
        roleId: roleId,
        appliesToAllDepartments: appliesToAllDepartments,
        startAt: startAt,
        action: action,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      final insertedUsersManager = await usersManagerRemoteDataSource
          .submitUsersManager(usersManagerModel, requestMasterModel);
      return right(insertedUsersManager);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> updateUsersManager({
    required UsersManagerPageViewModel usersManagerViewerPage,
    required String updatedBy,
  }) async {
    try {
      final updatedUsersManager =
          await usersManagerRemoteDataSource.updateUsersManager(
        usersManagerViewerPage,
        updatedBy,
      );
      return right(updatedUsersManager);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> approveUsersManager({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required UsersManagerPageViewModel usersManagerModel,
  }) async {
    try {
      final approvedUsersManager =
          await usersManagerRemoteDataSource.approveUsersManager(
        approvalSequenceModel,
        requestUnlockedFields,
        usersManagerModel,
      );
      return right(approvedUsersManager);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UsersManagerPageEntity>> getAllUsersManagers({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  }) async {
    try {
      final usersManagersVeiw =
          await usersManagerRemoteDataSource.getAllUsersManagersView(
        user.id,
        departmentId,
        isManagerExpanded,
        isDepartmentManagerExpanded,
        isViewAll,
      );
      final approvalsView =
          await usersManagerRemoteDataSource.getAllApprovalsView();
      return right(UsersManagerPageEntity(
        usersManagersView: usersManagersVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>>
      fetchUsersManagerViewerPage({required int requestId}) async {
    try {
      final usersManagersVeiw = await usersManagerRemoteDataSource
          .getUsersManagerViewByRequestId(requestId);
      final approvalsView = await usersManagerRemoteDataSource
          .getApprovalViewByRequestId(requestId);
      return right(UsersManagerViewerPageEntity(
        usersManagersView: usersManagersVeiw,
        approval: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
