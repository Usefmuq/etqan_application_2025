part of 'vacation_bloc.dart';

@immutable
sealed class VacationState {}

final class VacationInitial extends VacationState {}

final class VacationLoading extends VacationState {}

final class VacationFailure extends VacationState {
  final String error;
  VacationFailure(this.error);
}

final class VacationSubmitSuccess extends VacationState {}

final class VacationUpdateSuccess extends VacationState {
  final VacationViewerPageEntity vacationViewerPageEntity;
  VacationUpdateSuccess(this.vacationViewerPageEntity);
}

final class VacationApproveSuccess extends VacationState {
  final VacationViewerPageEntity vacationViewerPageEntity;
  VacationApproveSuccess(this.vacationViewerPageEntity);
}

final class VacationShowAllSuccess extends VacationState {
  final VacationPageEntity vacationPage;
  VacationShowAllSuccess(this.vacationPage);
}
