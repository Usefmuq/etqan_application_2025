import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/vacation/data/datasources/vacation_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_model.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/repositories/vacation_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class VacationRepositoryImpl implements VacationRepository {
  final VacationRemoteDataSource vacationRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const VacationRepositoryImpl(
    this.vacationRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, VacationViewerPageEntity>> submitVacation({
    required String createdById,
    required String vacationTypeId,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
    required double daysCount,
  }) async {
    try {
      RequestMasterModel requestMasterModel = RequestMasterModel(
        userId: createdById,
        serviceId: ServicesConstants.vacationServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      VacationModel vacationModel = VacationModel(
        id: Uuid().v1(),
        createdById: createdById,
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        status: LookupConstants.requestStatusPending,
        requestId: -1,
        isActive: true,
        vacationTypeId: vacationTypeId,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
        daysCount: daysCount,
      );
      final insertedVacation = await vacationRemoteDataSource.submitVacation(
          vacationModel, requestMasterModel);
      return right(insertedVacation);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VacationViewerPageEntity>> updateVacation({
    required VacationsPageViewModel vacationViewerPage,
    required String updatedBy,
  }) async {
    try {
      final updatedVacation = await vacationRemoteDataSource.updateVacation(
        vacationViewerPage,
        updatedBy,
      );
      return right(updatedVacation);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VacationViewerPageEntity>> approveVacation({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required VacationsPageViewModel vacationModel,
  }) async {
    try {
      final approvedVacation = await vacationRemoteDataSource.approveVacation(
        approvalSequenceModel,
        requestUnlockedFields,
        vacationModel,
      );
      return right(approvedVacation);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VacationPageEntity>> getAllVacations({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  }) async {
    try {
      final vacationsVeiw = await vacationRemoteDataSource.getAllVacationsView(
        user.id,
        departmentId,
        isManagerExpanded,
        isDepartmentManagerExpanded,
        isViewAll,
      );
      final approvalsView =
          await vacationRemoteDataSource.getAllApprovalsView();
      return right(VacationPageEntity(
        vacationsView: vacationsVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VacationViewerPageEntity>> fetchVacationViewerPage(
      {required int requestId}) async {
    try {
      final vacationsVeiw =
          await vacationRemoteDataSource.getVacationViewByRequestId(requestId);
      final approvalsView =
          await vacationRemoteDataSource.getApprovalViewByRequestId(requestId);
      return right(VacationViewerPageEntity(
        vacationsView: vacationsVeiw,
        approval: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
