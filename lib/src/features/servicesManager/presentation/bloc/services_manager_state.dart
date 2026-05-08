part of 'services_manager_bloc.dart';

@immutable
sealed class ServicesManagerState {}

final class ServicesManagerInitial extends ServicesManagerState {}

final class ServicesManagerLoading extends ServicesManagerState {}

final class ServicesManagerFailure extends ServicesManagerState {
  final String error;
  ServicesManagerFailure(this.error);
}

final class ServicesManagerSubmitSuccess extends ServicesManagerState {}

final class ServicesManagerUpdateSuccess extends ServicesManagerState {
  final ServicesManagerViewerPageEntity servicesmanagerViewerPageEntity;
  ServicesManagerUpdateSuccess(this.servicesmanagerViewerPageEntity);
}

final class ServicesManagerApproveSuccess extends ServicesManagerState {
  final ServicesManagerViewerPageEntity servicesmanagerViewerPageEntity;
  ServicesManagerApproveSuccess(this.servicesmanagerViewerPageEntity);
}

final class ServicesManagerShowAllSuccess extends ServicesManagerState {
  final ServicesManagerPageEntity servicesmanagerPage;
  ServicesManagerShowAllSuccess(this.servicesmanagerPage);
}
