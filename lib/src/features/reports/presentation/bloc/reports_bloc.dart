import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/approve_reports.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/get_all_reportss.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/submit_reports.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/update_reports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final SubmitReports _submitReports;
  final UpdateReports _updateReports;
  final ApproveReports _approveReports;
  final GetAllReportss _getAllReportss;
  ReportsBloc({
    required SubmitReports submitReports,
    required UpdateReports updateReports,
    required ApproveReports approveReports,
    required GetAllReportss getAllReportss,
  })  : _submitReports = submitReports,
        _updateReports = updateReports,
        _approveReports = approveReports,
        _getAllReportss = getAllReportss,
        super(ReportsInitial()) {
    on<ReportsEvent>((event, emit) => emit(ReportsLoading()));
    on<ReportsSubmitEvent>(_onReportsSubmitEvent);
    on<ReportsUpdateEvent>(_onReportsUpdateEvent);
    on<ReportsApproveEvent>(_onReportsApproveEvent);
    on<ReportsGetAllReportssEvent>(_onReportsGetAllReportssEvent);
  }

  void _onReportsSubmitEvent(
    ReportsSubmitEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final response = await _submitReports(SubmitReportsParams(
      createdById: event.createdById,
      // status: event.status,
      // requestId: event.requestId,
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(ReportsFailure(failure.message)),
      (reports) {
        emit(ReportsSubmitSuccess());
      },
    );
  }

  void _onReportsUpdateEvent(
    ReportsUpdateEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final response = await _updateReports(UpdateReportsParams(
      reportsViewerPage: event.reportsViewerPage,
      updatedBy: event.updatedBy,
    ));
    response.fold(
      (failure) => emit(ReportsFailure(failure.message)),
      (reports) {
        emit(ReportsUpdateSuccess(reports));
      },
    );
  }

  void _onReportsApproveEvent(
    ReportsApproveEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final response = await _approveReports(ApproveReportsParams(
      approvalSequenceModel: event.approvalSequence,
      requestUnlockedFields: event.requestUnlockedFields,
      reportsModel: event.reportsModel,
    ));
    response.fold(
      (failure) => emit(ReportsFailure(failure.message)),
      (reports) {
        emit(ReportsApproveSuccess(reports));
      },
    );
  }

  void _onReportsGetAllReportssEvent(
    ReportsGetAllReportssEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final response = await _getAllReportss(GetAllReportssParams(
      user: event.user,
      departmentId: event.departmentId,
      isManagerExpanded: event.isManagerExpanded,
      isDepartmentManagerExpanded: event.isDepartmentManagerExpanded,
      isViewAll: event.isViewAll,
    ));
    response.fold(
      (failure) => emit(ReportsFailure(failure.message)),
      (reportss) {
        emit(ReportsShowAllSuccess(reportss));
      },
    );
  }
}
