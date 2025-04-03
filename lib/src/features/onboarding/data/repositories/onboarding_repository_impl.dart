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
import 'package:uuid/uuid.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource onboardingRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const OnboardingRepositoryImpl(
    this.onboardingRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, Onboarding>> submitOnboarding({
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
        serviceId: ServicesConstants.onboardingServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      OnboardingModel onboardingModel = OnboardingModel(
        id: Uuid().v1(),
        createdById: createdById,
        updatedAt: DateTime.now(),
        status: LookupConstants.requestStatusPending,
        requestId: 1,
        isActive: true,
        title: title,
        content: content,
        topics: topics,
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
    required String id,
    required String createdById,
    required String status,
    required int requestId,
    required bool isActive,
    required String title,
    required String content,
    required List<String> topics,
  }) async {
    try {
      OnboardingModel onboardingModel = OnboardingModel(
        id: id,
        createdById: createdById,
        updatedAt: DateTime.now(),
        status: status,
        requestId: requestId,
        isActive: isActive,
        title: title,
        content: content,
        topics: topics,
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
