import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/usecases/approve_users_manager.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/usecases/get_all_users_manager.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/usecases/submit_users_manager.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/usecases/update_users_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'users_manager_event.dart';
part 'users_manager_state.dart';

class UsersManagerBloc extends Bloc<UsersManagerEvent, UsersManagerState> {
  final SubmitUsersManager _submitUsersManager;
  final UpdateUsersManager _updateUsersManager;
  final ApproveUsersManager _approveUsersManager;
  final GetAllUsersManagers _getAllUsersManagers;
  UsersManagerBloc({
    required SubmitUsersManager submitUsersManager,
    required UpdateUsersManager updateUsersManager,
    required ApproveUsersManager approveUsersManager,
    required GetAllUsersManagers getAllUsersManagers,
  })  : _submitUsersManager = submitUsersManager,
        _updateUsersManager = updateUsersManager,
        _approveUsersManager = approveUsersManager,
        _getAllUsersManagers = getAllUsersManagers,
        super(UsersManagerInitial()) {
    on<UsersManagerEvent>((event, emit) => emit(UsersManagerLoading()));
    on<UsersManagerSubmitEvent>(_onUsersManagerSubmitEvent);
    on<UsersManagerUpdateEvent>(_onUsersManagerUpdateEvent);
    on<UsersManagerApproveEvent>(_onUsersManagerApproveEvent);
    on<UsersManagerGetAllUsersManagersEvent>(
        _onUsersManagerGetAllUsersManagersEvent);
  }

  void _onUsersManagerSubmitEvent(
    UsersManagerSubmitEvent event,
    Emitter<UsersManagerState> emit,
  ) async {
    final response = await _submitUsersManager(SubmitUsersManagerParams(
      createdById: event.createdById,
      userId: event.userId,
      roleId: event.roleId,
      startAt: event.startAt,
      endAt: event.endAt,
      action: event.action,
      notes: event.notes,
      departmentId: event.departmentId,
      appliesToAllDepartments: event.appliesToAllDepartments,
    ));
    response.fold(
      (failure) => emit(UsersManagerFailure(failure.message)),
      (usersManager) {
        emit(UsersManagerSubmitSuccess());
      },
    );
  }

  void _onUsersManagerUpdateEvent(
    UsersManagerUpdateEvent event,
    Emitter<UsersManagerState> emit,
  ) async {
    final response = await _updateUsersManager(UpdateUsersManagerParams(
      usersManagerViewerPage: event.usersManagerViewerPage,
      updatedBy: event.updatedBy,
    ));
    response.fold(
      (failure) => emit(UsersManagerFailure(failure.message)),
      (usersManager) {
        emit(UsersManagerUpdateSuccess(usersManager));
      },
    );
  }

  void _onUsersManagerApproveEvent(
    UsersManagerApproveEvent event,
    Emitter<UsersManagerState> emit,
  ) async {
    final response = await _approveUsersManager(ApproveUsersManagerParams(
      approvalSequenceModel: event.approvalSequence,
      requestUnlockedFields: event.requestUnlockedFields,
      usersManagerModel: event.usersManagerModel,
    ));
    response.fold(
      (failure) => emit(UsersManagerFailure(failure.message)),
      (usersManager) {
        emit(UsersManagerApproveSuccess(usersManager));
      },
    );
  }

  void _onUsersManagerGetAllUsersManagersEvent(
    UsersManagerGetAllUsersManagersEvent event,
    Emitter<UsersManagerState> emit,
  ) async {
    final response = await _getAllUsersManagers(GetAllUsersManagersParams(
      user: event.user,
      departmentId: event.departmentId,
      isManagerExpanded: event.isManagerExpanded,
      isDepartmentManagerExpanded: event.isDepartmentManagerExpanded,
      isViewAll: event.isViewAll,
    ));
    response.fold(
      (failure) => emit(UsersManagerFailure(failure.message)),
      (usersManagers) {
        emit(UsersManagerShowAllSuccess(usersManagers));
      },
    );
  }
}
