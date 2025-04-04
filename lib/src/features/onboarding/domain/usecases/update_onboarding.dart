import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateOnboarding
    implements Usecase<OnboardingViewerPageEntity, UpdateOnboardingParams> {
  final OnboardingRepository onboardingRepostory;
  UpdateOnboarding(this.onboardingRepostory);
  @override
  Future<Either<Failure, OnboardingViewerPageEntity>> call(
      UpdateOnboardingParams params) async {
    return await onboardingRepostory.updateOnboarding(
      onboardingsPageViewModel: params.onboardingsPageViewModel,
    );
  }
}

class UpdateOnboardingParams {
  final OnboardingsPageViewModel onboardingsPageViewModel;

  UpdateOnboardingParams({
    required this.onboardingsPageViewModel,
  });
}
