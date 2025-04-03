import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitOnboarding implements Usecase<Onboarding, SubmitOnboardingParams> {
  final OnboardingRepository onboardingRepostory;
  SubmitOnboarding(this.onboardingRepostory);
  @override
  Future<Either<Failure, Onboarding>> call(
      SubmitOnboardingParams params) async {
    return await onboardingRepostory.submitOnboarding(
      createdById: params.createdById,
      // status: params.status,
      // requestId: params.requestId,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class SubmitOnboardingParams {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  SubmitOnboardingParams({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}
