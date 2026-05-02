import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AttendanceRemoteDataSource {
  Future<AttendanceViewerPageEntity> submitAttendance(
      AttendanceSessionModel attendance, RequestMasterModel request);
  Future<AttendanceRegularizationViewerPageEntity>
      submitAttendanceRegularization(
          AttendanceRegularizationModel attendance, RequestMasterModel request);
  Future<AttendanceViewerPageEntity> updateAttendance(
    AttendancesPageViewModel attendance,
    String updatedBy,
  );
  Future<AttendanceRegularizationViewerPageEntity>
      updateAttendanceRegularization(
    AttendanceRegularizationViewModel attendanceregularizationregularization,
    String updatedBy,
  );
  Future<AttendanceViewerPageEntity> approveAttendance(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    AttendancesPageViewModel attendance,
  );
  Future<List<AttendanceRegularizationViewModel>>
      getAllAttendancesRegularizationView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  );
  Future<AttendancesPageViewModel> getAttendanceViewByRequestId(int requestId);
  Future<AttendanceRegularizationViewModel>
      getAttendanceRegularizationViewByRequestId(int requestId);
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView();
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final SupabaseClient supabaseClient;
  AttendanceRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<AttendanceViewerPageEntity> submitAttendance(
    AttendanceSessionModel attendance,
    RequestMasterModel request,
  ) async {
    try {
      // SUBMIT Check in
      if (attendance.endAt.isNullOrEmpty) {
        await supabaseClient.rpc('start_attendance', params: {
          'p_source_key': attendance.sourceKey,
          'p_site_id': attendance.siteId,
          'p_inside_site': attendance.insideSite,
          'p_note': attendance.note,
          'p_start_lat': attendance.startLat,
          'p_start_lng': attendance.startLng,
          'p_start_accuracy_m': null,
        });
        final attendancesView = AttendancesPageViewModel();
        final approvals = [ApprovalSequenceViewModel()];

        return AttendanceViewerPageEntity(
          attendancesView: attendancesView,
          approval: approvals,
        );
      }
      // SUBMIT Check out
      else {
        await supabaseClient.rpc('end_attendance', params: {
          'p_site_id': attendance.siteId,
          'p_inside_site': attendance.insideSite,
          'p_note': attendance.note,
          'p_end_lat': attendance.endLat,
          'p_end_lng': attendance.endLng,
          'p_end_accuracy_m': null,
        });
        final attendancesView = AttendancesPageViewModel();
        final approvals = [ApprovalSequenceViewModel()];

        return AttendanceViewerPageEntity(
          attendancesView: attendancesView,
          approval: approvals,
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendanceViewerPageEntity> updateAttendance(
    AttendancesPageViewModel attendanceViewerPage,
    String updatedBy,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_update_generic', params: {
        'p_service_id': ServicesConstants.attendanceServiceId,
        'p_entity_table': 'attendances',
        'p_view_name': 'attendances_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': attendanceViewerPage.requestId,
        'p_updated_by': updatedBy,
        'p_entity': {
          'title': attendanceViewerPage.title,
          'content': attendanceViewerPage.content,
          'topics':
              attendanceViewerPage.topics ?? <String>[], // if present in table
        },
      });
      final attendancesView = AttendancesPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return AttendanceViewerPageEntity(
        attendancesView: attendancesView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendanceRegularizationViewerPageEntity>
      updateAttendanceRegularization(
    AttendanceRegularizationViewModel attendanceregularizationViewerPage,
    String updatedBy,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_update_generic', params: {
        'p_service_id': ServicesConstants.attendanceRegularizationServiceId,
        'p_entity_table': 'attendance_regularizations',
        'p_view_name': 'attendance_regularizations_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': attendanceregularizationViewerPage.requestId,
        'p_updated_by': updatedBy,
        'p_entity': {
          'start_date':
              attendanceregularizationViewerPage.startDate.toIso8601String(),
          'end_date':
              attendanceregularizationViewerPage.endDate.toIso8601String(),
          'include_weekends':
              attendanceregularizationViewerPage.includeWeekends,
          'proposed_check_in':
              attendanceregularizationViewerPage.proposedCheckIn,
          'proposed_check_out':
              attendanceregularizationViewerPage.proposedCheckOut,
          'reason': attendanceregularizationViewerPage.reason,
        },
      });
      final attendanceregularizationsView =
          AttendanceRegularizationViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return AttendanceRegularizationViewerPageEntity(
        attendancesView: attendanceregularizationsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendanceViewerPageEntity> approveAttendance(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    AttendancesPageViewModel attendance,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_approve_generic', params: {
        'p_entity_table': 'attendances',
        'p_view_name': 'attendances_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': approvalSequence.requestId,
        'p_approval_id': approvalSequence.approvalId,
        'p_status_id': approvalSequence.approvalStatus,
        'p_comment': approvalSequence.approverComment ?? '',
        'p_approved_by': approvalSequence.approvedBy,
        'p_unlocked_fields':
            (requestUnlockedFields ?? []).map((e) => e.toJson()).toList(),
      });
      final attendancesView = AttendancesPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return AttendanceViewerPageEntity(
        attendancesView: attendancesView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AttendanceRegularizationViewModel>>
      getAllAttendancesRegularizationView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  ) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
      };

      if (!isViewAll) {
        if (isDepartmentManagerExpanded) {
          if (departmentId.isNullOrEmpty) {
            return [];
          }
          filters['department_id'] = departmentId!;
        } else if (isManagerExpanded) {
          if (userId.isNullOrEmpty) {
            return [];
          }

          filters['report_to'] = userId;
        } else {
          if (userId.isNullOrEmpty) {
            return [];
          }

          filters['created_by_id'] = userId;
        }
      }

      final result = await supabaseClient
          .from('attendance_regularizations_view')
          .select('*')
          .match(filters)
          .order('request_updated_at', ascending: false);

      return result
          .map((attendance) =>
              AttendanceRegularizationViewModel.fromJson(attendance))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendancesPageViewModel> getAttendanceViewByRequestId(
      int requestId) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
        'request_id': requestId,
      };

      final Map<String, dynamic>? row = await supabaseClient
          .from('attendances_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        throw ServerException('Result view not found');
      }

      return AttendancesPageViewModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendanceRegularizationViewModel>
      getAttendanceRegularizationViewByRequestId(int requestId) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
        'request_id': requestId,
      };

      final Map<String, dynamic>? row = await supabaseClient
          .from('attendance_regularizations_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        throw ServerException('Result view not found');
      }

      return AttendanceRegularizationViewModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView() async {
    try {
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq('service_id', ServicesConstants.attendanceServiceId)
          .eq('is_active', true);
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId) async {
    try {
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq('request_id', requestId)
          .eq('is_active', true);
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AttendanceRegularizationViewerPageEntity>
      submitAttendanceRegularization(
    AttendanceRegularizationModel attendance,
    RequestMasterModel request,
  ) async {
    try {
      // SUBMIT
      final submitRes =
          await supabaseClient.rpc('rpc_service_submit_generic', params: {
        'p_service_id':
            ServicesConstants.attendanceRegularizationServiceId, // int
        'p_entity_table': 'attendance_regularizations',
        'p_view_name': 'attendance_regularizations_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request': request.toJson(),
        'p_entity': attendance
            .toJson(), // no need to include request_id; RPC injects it
      });
      final attendanceregularizationsView =
          AttendanceRegularizationViewModel.fromJson(submitRes['view']);
      final approvals = (submitRes['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return AttendanceRegularizationViewerPageEntity(
        attendancesView: attendanceregularizationsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
