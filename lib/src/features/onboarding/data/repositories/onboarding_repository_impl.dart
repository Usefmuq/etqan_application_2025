import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource onboardingRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const OnboardingRepositoryImpl(
    this.onboardingRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, Onboarding>> submitOnboarding({
    required String createdBy,
    required String firstNameEn,
    required String lastNameEn,
    required String firstNameAr,
    required String lastNameAr,
    required String email,
    required String phone,
    required String departmentId,
    required String positionId,
    required String reportTo,
    required DateTime startDate,
    required String notes,
  }) async {
    try {
      RequestMasterModel requestMasterModel = RequestMasterModel(
        // requestId: 0,
        userId: createdBy,
        serviceId: ServicesConstants.onboardingServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      OnboardingModel onboardingModel = OnboardingModel(
        // onboardingId: onboardingId,
        firstNameEn: firstNameEn,
        lastNameEn: lastNameEn,
        firstNameAr: firstNameAr,
        lastNameAr: lastNameAr,
        email: email,
        phone: phone,
        departmentId: departmentId,
        positionId: positionId,
        reportTo: reportTo,
        startDate: startDate,
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        status: LookupConstants.requestStatusPending,
        isActive: true,
        createdBy: createdBy,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        notes: notes,
      );
      final insertedOnboarding = await onboardingRemoteDataSource
          .submitOnboarding(onboardingModel, requestMasterModel);
      return right(insertedOnboarding);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingViewerPageEntity>> updateOnboarding({
    required OnboardingsPageViewModel onboardingsPageViewModel,
  }) async {
    try {
      OnboardingModel onboardingModel = OnboardingModel(
        onboardingId: onboardingsPageViewModel.onboardingId,
        firstNameEn: onboardingsPageViewModel.firstNameEn,
        lastNameEn: onboardingsPageViewModel.lastNameEn,
        firstNameAr: onboardingsPageViewModel.firstNameAr,
        lastNameAr: onboardingsPageViewModel.lastNameAr,
        email: onboardingsPageViewModel.email,
        phone: onboardingsPageViewModel.phone,
        departmentId: onboardingsPageViewModel.departmentId,
        positionId: onboardingsPageViewModel.positionId,
        reportTo: onboardingsPageViewModel.reportTo,
        startDate: onboardingsPageViewModel.startDate,
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        status: onboardingsPageViewModel.statusId,
        isActive: onboardingsPageViewModel.isActive,
        createdBy: onboardingsPageViewModel.createdBy,
        createdAt: onboardingsPageViewModel.createdAt,
        notes: onboardingsPageViewModel.notes,
      );
      final updatedOnboarding =
          await onboardingRemoteDataSource.updateOnboarding(onboardingModel);
      return right(updatedOnboarding);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingViewerPageEntity>> approveOnboarding({
    required ApprovalSequenceViewModel approvalSequenceModel,
    required OnboardingsPageViewModel onboardingModel,
  }) async {
    try {
      final approvedOnboarding =
          await onboardingRemoteDataSource.approveOnboarding(
        approvalSequenceModel,
        onboardingModel,
      );
      return right(approvedOnboarding);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingPageEntity>> getAllOnboardings() async {
    try {
      final onboardingsVeiw =
          await onboardingRemoteDataSource.getAllOnboardingsView();
      final approvalsView =
          await onboardingRemoteDataSource.getAllApprovalsView();
      return right(OnboardingPageEntity(
        onboardingsView: onboardingsVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
