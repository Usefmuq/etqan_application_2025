import 'package:etqan_application_2025/src/core/common/entities/user_roles.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/data/models/user_roles_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UsersManagerRemoteDataSource {
  Future<UsersManagerViewerPageEntity> submitUsersManager(
      UsersManagerModel usersManager, RequestMasterModel request);
  Future<UsersManagerViewerPageEntity> updateUsersManager(
    UsersManagerPageViewModel usersManager,
    String updatedBy,
  );
  Future<UsersManagerViewerPageEntity> approveUsersManager(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    UsersManagerPageViewModel usersManager,
  );
  Future<List<UsersManagerPageViewModel>> getAllUsersManagersView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  );
  Future<UsersManagerPageViewModel> getUsersManagerViewByRequestId(
      int requestId);
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView();
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId);
}

class UsersManagerRemoteDataSourceImpl implements UsersManagerRemoteDataSource {
  final SupabaseClient supabaseClient;
  UsersManagerRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<UsersManagerViewerPageEntity> submitUsersManager(
    UsersManagerModel usersManager,
    RequestMasterModel request,
  ) async {
    try {
      // SUBMIT
      final submitRes =
          await supabaseClient.rpc('rpc_service_submit_generic', params: {
        'p_service_id': ServicesConstants.usersManagerServiceId, // int
        'p_entity_table': 'users_manager_service',
        'p_view_name': 'users_manager_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request': request.toJson(),
        'p_entity': usersManager
            .toJson(), // no need to include request_id; RPC injects it
      });
      final usersManagersView =
          UsersManagerPageViewModel.fromJson(submitRes['view']);
      final approvals = (submitRes['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();
      if (usersManagersView.requestStatusId ==
          LookupConstants.requestStatusCompleted) {
        await supabaseClient.from('userroles').insert(
              UserRolesModel(
                userId: usersManagersView.userId,
                roleId: usersManagersView.roleId,
                createdAt: usersManagersView.createdAt,
                updatedAt: usersManagersView.updatedAt,
                departmentId: usersManagersView.departmentId,
                startDate: usersManagersView.startAt,
                allDepartments: usersManagersView.appliesToAllDepartments,
                endDate: usersManagersView.endAt,
                assignedBy: usersManagersView.createdById,
              ).toJson(),
            );
      }

      return UsersManagerViewerPageEntity(
        usersManagersView: usersManagersView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UsersManagerViewerPageEntity> updateUsersManager(
    UsersManagerPageViewModel usersManagerViewerPage,
    String updatedBy,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_update_generic', params: {
        'p_service_id': ServicesConstants.usersManagerServiceId,
        'p_entity_table': 'users_manager_service',
        'p_view_name': 'users_manager_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': usersManagerViewerPage.requestId,
        'p_updated_by': updatedBy,
        'p_entity': {
          // 'title': usersManagerViewerPage.title,
          // 'content': usersManagerViewerPage.content,
          // 'topics': usersManagerViewerPage.topics ??
          //     <String>[], // if present in table
        },
      });
      final usersManagersView = UsersManagerPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return UsersManagerViewerPageEntity(
        usersManagersView: usersManagersView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UsersManagerViewerPageEntity> approveUsersManager(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    UsersManagerPageViewModel usersManager,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_approve_generic', params: {
        'p_entity_table': 'users_manager_service',
        'p_view_name': 'users_manager_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': approvalSequence.requestId,
        'p_approval_id': approvalSequence.approvalId,
        'p_status_id': approvalSequence.approvalStatus,
        'p_comment': approvalSequence.approverComment ?? '',
        'p_approved_by': approvalSequence.approvedBy,
        'p_unlocked_fields':
            (requestUnlockedFields ?? []).map((e) => e.toJson()).toList(),
      });
      final usersManagersView = UsersManagerPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return UsersManagerViewerPageEntity(
        usersManagersView: usersManagersView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<UsersManagerPageViewModel>> getAllUsersManagersView(
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
          .from('users_manager_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false);

      return result
          .map((usersManager) =>
              UsersManagerPageViewModel.fromJson(usersManager))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UsersManagerPageViewModel> getUsersManagerViewByRequestId(
      int requestId) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
        'request_id': requestId,
      };

      final Map<String, dynamic>? row = await supabaseClient
          .from('users_manager_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        throw ServerException('Result view not found');
      }

      return UsersManagerPageViewModel.fromJson(row);
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
          .eq('service_id', ServicesConstants.usersManagerServiceId)
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
