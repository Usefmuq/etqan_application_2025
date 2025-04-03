import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/approve_onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/get_all_onboardings.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/submit_onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/update_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SubmitOnboarding _submitOnboarding;
  final UpdateOnboarding _updateOnboarding;
  final ApproveOnboarding _approveOnboarding;
  final GetAllOnboardings _getAllOnboardings;
  OnboardingBloc({
    required SubmitOnboarding submitOnboarding,
    required UpdateOnboarding updateOnboarding,
    required ApproveOnboarding approveOnboarding,
    required GetAllOnboardings getAllOnboardings,
  })  : _submitOnboarding = submitOnboarding,
        _updateOnboarding = updateOnboarding,
        _approveOnboarding = approveOnboarding,
        _getAllOnboardings = getAllOnboardings,
        super(OnboardingInitial()) {
    on<OnboardingEvent>((event, emit) => emit(OnboardingLoading()));
    on<OnboardingSubmitEvent>(_onOnboardingSubmitEvent);
    on<OnboardingUpdateEvent>(_onOnboardingUpdateEvent);
    on<OnboardingApproveEvent>(_onOnboardingApproveEvent);
    on<OnboardingGetAllOnboardingsEvent>(_onOnboardingGetAllOnboardingsEvent);
  }

  void _onOnboardingSubmitEvent(
    OnboardingSubmitEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final response = await _submitOnboarding(SubmitOnboardingParams(
      createdById: event.createdById,
      // status: event.status,
      // requestId: event.requestId,
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (onboarding) {
        emit(OnboardingSubmitSuccess());
      },
    );
  }

  void _onOnboardingUpdateEvent(
    OnboardingUpdateEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final response = await _updateOnboarding(UpdateOnboardingParams(
      id: event.id,
      createdById: event.createdById,
      status: event.status,
      requestId: event.requestId,
      isActive: event.isActive,
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (onboarding) {
        emit(OnboardingUpdateSuccess(onboarding));
      },
    );
  }

  void _onOnboardingApproveEvent(
    OnboardingApproveEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final response = await _approveOnboarding(ApproveOnboardingParams(
      approvalSequenceModel: event.approvalSequence,
      onboardingModel: event.onboardingModel,
    ));
    response.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (onboarding) {
        emit(OnboardingApproveSuccess(onboarding));
      },
    );
  }

  void _onOnboardingGetAllOnboardingsEvent(
    OnboardingGetAllOnboardingsEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final response = await _getAllOnboardings(NoParams());
    response.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (onboardings) {
        emit(OnboardingShowAllSuccess(onboardings));
      },
    );
  }
}
