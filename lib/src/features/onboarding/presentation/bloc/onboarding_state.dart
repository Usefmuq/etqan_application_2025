part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingState {}

final class OnboardingInitial extends OnboardingState {}

final class OnboardingLoading extends OnboardingState {}

final class OnboardingFailure extends OnboardingState {
  final String error;
  OnboardingFailure(this.error);
}

final class OnboardingSubmitSuccess extends OnboardingState {}

final class OnboardingUpdateSuccess extends OnboardingState {
  final OnboardingViewerPageEntity onboardingViewerPageEntity;
  OnboardingUpdateSuccess(this.onboardingViewerPageEntity);
}

final class OnboardingApproveSuccess extends OnboardingState {
  final OnboardingViewerPageEntity onboardingViewerPageEntity;
  OnboardingApproveSuccess(this.onboardingViewerPageEntity);
}

final class OnboardingShowAllSuccess extends OnboardingState {
  final OnboardingPageEntity onboardingPage;
  OnboardingShowAllSuccess(this.onboardingPage);
}
