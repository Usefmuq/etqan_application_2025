import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveOnboarding
    implements Usecase<OnboardingViewerPageEntity, ApproveOnboardingParams> {
  final OnboardingRepository onboardingRepostory;
  ApproveOnboarding(this.onboardingRepostory);
  @override
  Future<Either<Failure, OnboardingViewerPageEntity>> call(
      ApproveOnboardingParams params) async {
    return await onboardingRepostory.approveOnboarding(
      approvalSequenceModel: params.approvalSequenceModel,
      onboardingModel: params.onboardingModel,
    );
  }
}

class ApproveOnboardingParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final OnboardingsPageViewModel onboardingModel;

  ApproveOnboardingParams({
    required this.approvalSequenceModel,
    required this.onboardingModel,
  });
}
