import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';

class OnboardingPageEntity {
  final List<OnboardingsPageViewModel> onboardingsView;
  final List<ApprovalSequenceViewModel> approvalsView;

  OnboardingPageEntity({
    required this.onboardingsView,
    required this.approvalsView,
  });
}
