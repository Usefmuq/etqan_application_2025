import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
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
      id: params.id,
      createdById: params.createdById,
      status: params.status,
      requestId: params.requestId,
      isActive: params.isActive,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class UpdateOnboardingParams {
  final String id;
  final String createdById;
  final String status;
  final int requestId;
  final bool isActive;
  final String title;
  final String content;
  final List<String> topics;

  UpdateOnboardingParams({
    required this.id,
    required this.createdById,
    required this.status,
    required this.requestId,
    required this.isActive,
    required this.title,
    required this.content,
    required this.topics,
  });
}
