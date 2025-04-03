import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllOnboardings implements Usecase<OnboardingPageEntity, NoParams> {
  final OnboardingRepository onboardingRepostory;
  GetAllOnboardings(this.onboardingRepostory);
  @override
  Future<Either<Failure, OnboardingPageEntity>> call(NoParams params) async {
    return await onboardingRepostory.getAllOnboardings();
  }
}
