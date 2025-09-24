part of 'users_manager_bloc.dart';

@immutable
sealed class UsersManagerEvent {}

final class UsersManagerSubmitEvent extends UsersManagerEvent {
  final String createdById;
  final String userId;
  final String roleId;
  final DateTime startAt;
  final DateTime? endAt;
  final String action;
  final String notes;
  final String departmentId;
  final bool appliesToAllDepartments;

  UsersManagerSubmitEvent({
    required this.createdById,
    required this.userId,
    required this.roleId,
    required this.startAt,
    required this.endAt,
    required this.action,
    required this.notes,
    required this.departmentId,
    required this.appliesToAllDepartments,
  });
}

final class UsersManagerUpdateEvent extends UsersManagerEvent {
  final UsersManagerPageViewModel usersManagerViewerPage;
  final String updatedBy;

  UsersManagerUpdateEvent({
    required this.usersManagerViewerPage,
    required this.updatedBy,
  });
}

final class UsersManagerApproveEvent extends UsersManagerEvent {
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;
  final UsersManagerPageViewModel usersManagerModel;

  UsersManagerApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.usersManagerModel,
  });
}

final class UsersManagerGetAllUsersManagersEvent extends UsersManagerEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  UsersManagerGetAllUsersManagersEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
