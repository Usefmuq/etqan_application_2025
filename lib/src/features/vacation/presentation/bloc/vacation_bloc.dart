import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/usecases/approve_vacation.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/usecases/get_all_vacations.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/usecases/submit_vacation.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/usecases/update_vacation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vacation_event.dart';
part 'vacation_state.dart';

class VacationBloc extends Bloc<VacationEvent, VacationState> {
  final SubmitVacation _submitVacation;
  final UpdateVacation _updateVacation;
  final ApproveVacation _approveVacation;
  final GetAllVacations _getAllVacations;
  VacationBloc({
    required SubmitVacation submitVacation,
    required UpdateVacation updateVacation,
    required ApproveVacation approveVacation,
    required GetAllVacations getAllVacations,
  })  : _submitVacation = submitVacation,
        _updateVacation = updateVacation,
        _approveVacation = approveVacation,
        _getAllVacations = getAllVacations,
        super(VacationInitial()) {
    on<VacationEvent>((event, emit) => emit(VacationLoading()));
    on<VacationSubmitEvent>(_onVacationSubmitEvent);
    on<VacationUpdateEvent>(_onVacationUpdateEvent);
    on<VacationApproveEvent>(_onVacationApproveEvent);
    on<VacationGetAllVacationsEvent>(_onVacationGetAllVacationsEvent);
  }

  void _onVacationSubmitEvent(
    VacationSubmitEvent event,
    Emitter<VacationState> emit,
  ) async {
    final response = await _submitVacation(SubmitVacationParams(
      createdById: event.createdById,
      vacationTypeId: event.vacationTypeId,
      reason: event.reason,
      startDate: event.startDate,
      endDate: event.endDate,
      daysCount: event.daysCount,
    ));
    response.fold(
      (failure) => emit(VacationFailure(failure.message)),
      (vacation) {
        emit(VacationSubmitSuccess());
      },
    );
  }

  void _onVacationUpdateEvent(
    VacationUpdateEvent event,
    Emitter<VacationState> emit,
  ) async {
    final response = await _updateVacation(UpdateVacationParams(
      vacationViewerPage: event.vacationViewerPage,
      updatedBy: event.updatedBy,
    ));
    response.fold(
      (failure) => emit(VacationFailure(failure.message)),
      (vacation) {
        emit(VacationUpdateSuccess(vacation));
      },
    );
  }

  void _onVacationApproveEvent(
    VacationApproveEvent event,
    Emitter<VacationState> emit,
  ) async {
    final response = await _approveVacation(ApproveVacationParams(
      approvalSequenceModel: event.approvalSequence,
      requestUnlockedFields: event.requestUnlockedFields,
      vacationModel: event.vacationModel,
    ));
    response.fold(
      (failure) => emit(VacationFailure(failure.message)),
      (vacation) {
        emit(VacationApproveSuccess(vacation));
      },
    );
  }

  void _onVacationGetAllVacationsEvent(
    VacationGetAllVacationsEvent event,
    Emitter<VacationState> emit,
  ) async {
    final response = await _getAllVacations(GetAllVacationsParams(
      user: event.user,
      departmentId: event.departmentId,
      isManagerExpanded: event.isManagerExpanded,
      isDepartmentManagerExpanded: event.isDepartmentManagerExpanded,
      isViewAll: event.isViewAll,
    ));
    response.fold(
      (failure) => emit(VacationFailure(failure.message)),
      (vacations) {
        emit(VacationShowAllSuccess(vacations));
      },
    );
  }
}
