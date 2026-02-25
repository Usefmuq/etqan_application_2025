part of 'reports_bloc.dart';

@immutable
sealed class ReportsState {}

final class ReportsInitial extends ReportsState {}

final class ReportsLoading extends ReportsState {}

final class ReportsFailure extends ReportsState {
  final String error;
  ReportsFailure(this.error);
}

final class ReportsSubmitSuccess extends ReportsState {}

final class ReportsUpdateSuccess extends ReportsState {
  final ReportsViewerPageEntity reportsViewerPageEntity;
  ReportsUpdateSuccess(this.reportsViewerPageEntity);
}

final class ReportsApproveSuccess extends ReportsState {
  final ReportsViewerPageEntity reportsViewerPageEntity;
  ReportsApproveSuccess(this.reportsViewerPageEntity);
}

final class ReportsShowAllSuccess extends ReportsState {
  final ReportsPageEntity reportsPage;
  ReportsShowAllSuccess(this.reportsPage);
}
