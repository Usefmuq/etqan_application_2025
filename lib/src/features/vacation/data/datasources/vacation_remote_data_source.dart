import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_model.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class VacationRemoteDataSource {
  Future<VacationViewerPageEntity> submitVacation(
      VacationModel vacation, RequestMasterModel request);
  Future<VacationViewerPageEntity> updateVacation(
    VacationsPageViewModel vacation,
    String updatedBy,
  );
  Future<VacationViewerPageEntity> approveVacation(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    VacationsPageViewModel vacation,
  );
  Future<List<VacationsPageViewModel>> getAllVacationsView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  );
  Future<VacationsPageViewModel> getVacationViewByRequestId(int requestId);
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView();
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId);
}

class VacationRemoteDataSourceImpl implements VacationRemoteDataSource {
  final SupabaseClient supabaseClient;
  VacationRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<VacationViewerPageEntity> submitVacation(
    VacationModel vacation,
    RequestMasterModel request,
  ) async {
    try {
      // SUBMIT
      final submitRes =
          await supabaseClient.rpc('rpc_service_submit_generic', params: {
        'p_service_id': ServicesConstants.vacationServiceId, // int
        'p_entity_table': 'vacations',
        'p_view_name': 'vacations_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request': request.toJson(),
        'p_entity': vacation.toJson(),
      });
      final vacationsView = VacationsPageViewModel.fromJson(submitRes['view']);
      final approvals = (submitRes['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return VacationViewerPageEntity(
        vacationsView: vacationsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VacationViewerPageEntity> updateVacation(
    VacationsPageViewModel vacationViewerPage,
    String updatedBy,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_update_generic', params: {
        'p_service_id': ServicesConstants.vacationServiceId,
        'p_entity_table': 'vacations',
        'p_view_name': 'vacations_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': vacationViewerPage.requestId,
        'p_updated_by': updatedBy,
        'p_entity': {
          'vacationTypeId': vacationViewerPage.vacationTypeId,
          'reason': vacationViewerPage.reason,
          'startDate': vacationViewerPage.startDate?.toIso8601String(),
          'endDate': vacationViewerPage.endDate?.toIso8601String(),
          'daysCount': vacationViewerPage.daysCount,
        },
      });
      final vacationsView = VacationsPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return VacationViewerPageEntity(
        vacationsView: vacationsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VacationViewerPageEntity> approveVacation(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    VacationsPageViewModel vacation,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_approve_generic', params: {
        'p_entity_table': 'vacations',
        'p_view_name': 'vacations_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': approvalSequence.requestId,
        'p_approval_id': approvalSequence.approvalId,
        'p_status_id': approvalSequence.approvalStatus,
        'p_comment': approvalSequence.approverComment ?? '',
        'p_approved_by': approvalSequence.approvedBy,
        'p_unlocked_fields':
            (requestUnlockedFields ?? []).map((e) => e.toJson()).toList(),
      });
      final vacationsView = VacationsPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return VacationViewerPageEntity(
        vacationsView: vacationsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<VacationsPageViewModel>> getAllVacationsView(
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
          .from('vacations_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false);

      return result
          .map((vacation) => VacationsPageViewModel.fromJson(vacation))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VacationsPageViewModel> getVacationViewByRequestId(
      int requestId) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
        'request_id': requestId,
      };

      final Map<String, dynamic>? row = await supabaseClient
          .from('vacations_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        throw ServerException('Result view not found');
      }

      return VacationsPageViewModel.fromJson(row);
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
          .eq('service_id', ServicesConstants.vacationServiceId)
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
}
