import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';

class OnboardingViewerPageEntity {
  final OnboardingsPageViewModel onboardingsView;

  final List<ApprovalSequenceViewModel>? approval;

  OnboardingViewerPageEntity({
    required this.onboardingsView,
    this.approval,
  });
}
