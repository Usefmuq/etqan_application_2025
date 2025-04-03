import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class OnboardingRepository {
  Future<Either<Failure, Onboarding>> submitOnboarding({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, OnboardingViewerPageEntity>> updateOnboarding({
    required String id,
    required String createdById,
    required String status,
    required int requestId,
    required bool isActive,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, OnboardingViewerPageEntity>> approveOnboarding({
    required ApprovalSequenceViewModel approvalSequenceModel,
    required OnboardingsPageViewModel onboardingModel,
  });
  Future<Either<Failure, OnboardingPageEntity>> getAllOnboardings();
}
