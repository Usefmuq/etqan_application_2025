import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ServicesManagerRemoteDataSource {
  Future<ServicesManagerViewerPageEntity> submitServicesManager(
      ServicesManagerModel servicesmanager, RequestMasterModel request);
  Future<ServicesManagerViewerPageEntity> updateServicesManager(
    ServicesManagersPageViewModel servicesmanager,
    String updatedBy,
  );
  Future<ServicesManagerViewerPageEntity> approveServicesManager(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    ServicesManagersPageViewModel servicesmanager,
  );
  Future<List<ServicesManagersPageViewModel>> getAllServicesManagersView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  );
  Future<ServicesManagersPageViewModel> getServicesManagerViewByRequestId(
      int requestId);
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView();
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId);
}

class ServicesManagerRemoteDataSourceImpl
    implements ServicesManagerRemoteDataSource {
  final SupabaseClient supabaseClient;
  ServicesManagerRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<ServicesManagerViewerPageEntity> submitServicesManager(
    ServicesManagerModel servicesmanager,
    RequestMasterModel request,
  ) async {
    try {
      // SUBMIT
      final submitRes =
          await supabaseClient.rpc('rpc_service_submit_generic', params: {
        'p_service_id': ServicesConstants.servicesManagerServiceId, // int
        'p_entity_table': 'servicesmanagers',
        'p_view_name': 'servicesmanagers_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request': request.toJson(),
        'p_entity': servicesmanager
            .toJson(), // no need to include request_id; RPC injects it
      });
      final servicesmanagersView =
          ServicesManagersPageViewModel.fromJson(submitRes['view']);
      final approvals = (submitRes['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return ServicesManagerViewerPageEntity(
        servicesmanagersView: servicesmanagersView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ServicesManagerViewerPageEntity> updateServicesManager(
    ServicesManagersPageViewModel servicesmanagerViewerPage,
    String updatedBy,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_update_generic', params: {
        'p_service_id': ServicesConstants.servicesManagerServiceId,
        'p_entity_table': 'servicesmanagers',
        'p_view_name': 'servicesmanagers_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': servicesmanagerViewerPage.requestId,
        'p_updated_by': updatedBy,
        'p_entity': {
          'title': servicesmanagerViewerPage.title,
          'content': servicesmanagerViewerPage.content,
          'topics': servicesmanagerViewerPage.topics ??
              <String>[], // if present in table
        },
      });
      final servicesmanagersView =
          ServicesManagersPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return ServicesManagerViewerPageEntity(
        servicesmanagersView: servicesmanagersView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ServicesManagerViewerPageEntity> approveServicesManager(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    ServicesManagersPageViewModel servicesmanager,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_approve_generic', params: {
        'p_entity_table': 'servicesmanagers',
        'p_view_name': 'servicesmanagers_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': approvalSequence.requestId,
        'p_approval_id': approvalSequence.approvalId,
        'p_status_id': approvalSequence.approvalStatus,
        'p_comment': approvalSequence.approverComment ?? '',
        'p_approved_by': approvalSequence.approvedBy,
        'p_unlocked_fields':
            (requestUnlockedFields ?? []).map((e) => e.toJson()).toList(),
      });
      final servicesmanagersView =
          ServicesManagersPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return ServicesManagerViewerPageEntity(
        servicesmanagersView: servicesmanagersView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ServicesManagersPageViewModel>> getAllServicesManagersView(
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
          .from('servicesmanagers_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false);

      return result
          .map((servicesmanager) =>
              ServicesManagersPageViewModel.fromJson(servicesmanager))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ServicesManagersPageViewModel> getServicesManagerViewByRequestId(
      int requestId) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
        'request_id': requestId,
      };

      final Map<String, dynamic>? row = await supabaseClient
          .from('servicesmanagers_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        throw ServerException('Result view not found');
      }

      return ServicesManagersPageViewModel.fromJson(row);
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
          .eq('service_id', ServicesConstants.servicesManagerServiceId)
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
