import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/get_all_reportss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetAllReportss _getAllReportss;
  ReportsBloc({
    required GetAllReportss getAllReportss,
  })  : _getAllReportss = getAllReportss,
        super(ReportsInitial()) {
    on<ReportsEvent>((event, emit) => emit(ReportsLoading()));
    on<ReportsGetAllReportssEvent>(_onReportsGetAllReportssEvent);
  }
  void _onReportsGetAllReportssEvent(
    ReportsGetAllReportssEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final response = await _getAllReportss(GetAllReportssParams());
    response.fold(
      (failure) => emit(ReportsFailure(failure.message)),
      (reportss) {
        emit(ReportsShowAllSuccess(reportss));
      },
    );
  }
}
