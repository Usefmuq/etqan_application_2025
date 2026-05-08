import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/usecases/approve_services_manager.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/usecases/get_all_services_managers.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/usecases/submit_services_manager.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/usecases/update_services_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'services_manager_event.dart';
part 'services_manager_state.dart';

class ServicesManagerBloc
    extends Bloc<ServicesManagerEvent, ServicesManagerState> {
  final SubmitServicesManager _submitServicesManager;
  final UpdateServicesManager _updateServicesManager;
  final ApproveServicesManager _approveServicesManager;
  final GetAllServicesManagers _getAllServicesManagers;
  ServicesManagerBloc({
    required SubmitServicesManager submitServicesManager,
    required UpdateServicesManager updateServicesManager,
    required ApproveServicesManager approveServicesManager,
    required GetAllServicesManagers getAllServicesManagers,
  })  : _submitServicesManager = submitServicesManager,
        _updateServicesManager = updateServicesManager,
        _approveServicesManager = approveServicesManager,
        _getAllServicesManagers = getAllServicesManagers,
        super(ServicesManagerInitial()) {
    on<ServicesManagerEvent>((event, emit) => emit(ServicesManagerLoading()));
    on<ServicesManagerSubmitEvent>(_onServicesManagerSubmitEvent);
    on<ServicesManagerUpdateEvent>(_onServicesManagerUpdateEvent);
    on<ServicesManagerApproveEvent>(_onServicesManagerApproveEvent);
    on<ServicesManagerGetAllServicesManagersEvent>(
        _onServicesManagerGetAllServicesManagersEvent);
  }

  void _onServicesManagerSubmitEvent(
    ServicesManagerSubmitEvent event,
    Emitter<ServicesManagerState> emit,
  ) async {
    final response = await _submitServicesManager(SubmitServicesManagerParams(
      createdById: event.createdById,
      // status: event.status,
      // requestId: event.requestId,
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(ServicesManagerFailure(failure.message)),
      (servicesmanager) {
        emit(ServicesManagerSubmitSuccess());
      },
    );
  }

  void _onServicesManagerUpdateEvent(
    ServicesManagerUpdateEvent event,
    Emitter<ServicesManagerState> emit,
  ) async {
    final response = await _updateServicesManager(UpdateServicesManagerParams(
      servicesmanagerViewerPage: event.servicesmanagerViewerPage,
      updatedBy: event.updatedBy,
    ));
    response.fold(
      (failure) => emit(ServicesManagerFailure(failure.message)),
      (servicesmanager) {
        emit(ServicesManagerUpdateSuccess(servicesmanager));
      },
    );
  }

  void _onServicesManagerApproveEvent(
    ServicesManagerApproveEvent event,
    Emitter<ServicesManagerState> emit,
  ) async {
    final response = await _approveServicesManager(ApproveServicesManagerParams(
      approvalSequenceModel: event.approvalSequence,
      requestUnlockedFields: event.requestUnlockedFields,
      servicesmanagerModel: event.servicesmanagerModel,
    ));
    response.fold(
      (failure) => emit(ServicesManagerFailure(failure.message)),
      (servicesmanager) {
        emit(ServicesManagerApproveSuccess(servicesmanager));
      },
    );
  }

  void _onServicesManagerGetAllServicesManagersEvent(
    ServicesManagerGetAllServicesManagersEvent event,
    Emitter<ServicesManagerState> emit,
  ) async {
    final response = await _getAllServicesManagers(GetAllServicesManagersParams(
      user: event.user,
      departmentId: event.departmentId,
      isManagerExpanded: event.isManagerExpanded,
      isDepartmentManagerExpanded: event.isDepartmentManagerExpanded,
      isViewAll: event.isViewAll,
    ));
    response.fold(
      (failure) => emit(ServicesManagerFailure(failure.message)),
      (servicesmanagers) {
        emit(ServicesManagerShowAllSuccess(servicesmanagers));
      },
    );
  }
}
