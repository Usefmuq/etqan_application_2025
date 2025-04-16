import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/user_sign_up.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class OnboardingRemoteDataSource {
  Future<OnboardingModel> submitOnboarding(
      OnboardingModel onboarding, RequestMasterModel request);
  Future<OnboardingViewerPageEntity> updateOnboarding(
      OnboardingModel onboarding);
  Future<OnboardingViewerPageEntity> approveOnboarding(
    ApprovalSequenceViewModel approvalSequence,
    OnboardingsPageViewModel onboarding,
  );
  Future<List<OnboardingsPageViewModel>> getAllOnboardingsView();
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final SupabaseClient supabaseClient;
  OnboardingRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<OnboardingModel> submitOnboarding(
    OnboardingModel onboarding,
    RequestMasterModel request,
  ) async {
    try {
      final serviceAprovalUsersData = await supabaseClient
          .from('service_approval_users')
          .select('*')
          .eq('service_id', ServicesConstants.onboardingServiceId)
          .eq('is_active', true);
      final serviceApprovalUsers = serviceAprovalUsersData
          .map((item) => ServiceApprovalUsersModel.fromJson(item))
          .toList();
      final requestData = await supabaseClient
          .from('requests_master')
          .insert(
            request
                .copyWith(
                  status: serviceApprovalUsers.isNotEmpty
                      ? request.status
                      : LookupConstants.requestStatusCompleted,
                )
                .toJson(),
          )
          .select();
      final req = RequestMasterModel.fromJson(requestData.first);
      if (req.status == LookupConstants.requestStatusCompleted) {
        final userId = await _createUserViaFunction(
          email: onboarding.email,
          password: onboarding.phone ?? '123456',
          firstNameEn: onboarding.firstNameEn,
          lastNameEn: onboarding.lastNameEn,
          phone: onboarding.phone ?? '',
          departmentId: onboarding.departmentId ?? '',
          positionId: onboarding.positionId ?? '',
        );
        await supabaseClient.from('users').update(
          {
            'first_name_en': onboarding.firstNameEn,
            'first_name_ar': onboarding.firstNameAr,
            'last_name_en': onboarding.lastNameEn,
            'last_name_ar': onboarding.lastNameAr,
            'phone': onboarding.phone,
            'department_id': onboarding.departmentId,
            'position_id': onboarding.positionId,
            'status_id': LookupConstants.userStatusActive,
            'report_to': onboarding.reportTo,
          },
        ).eq('id', userId);
      }
      final approvalSequence = mapServiceApproversToApprovalSequence(
        requestId: req.requestId ?? -1,
        serviceApprovers: serviceApprovalUsers,
      );
      await supabaseClient
          .from('approval_sequence')
          .insert(
            approvalSequence.map((e) => e.toJson()).toList(),
          )
          .select();
      final onboardingData = await supabaseClient
          .from('employee_onboarding')
          .insert(
            onboarding
                .copyWith(
                  requestId: req.requestId,
                  status: serviceApprovalUsers.isNotEmpty
                      ? request.status
                      : LookupConstants.requestStatusCompleted,
                )
                .toJson(),
          )
          .select();

      return OnboardingModel.fromJson(onboardingData.first);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OnboardingViewerPageEntity> updateOnboarding(
      OnboardingModel onboarding) async {
    try {
      await supabaseClient
          .from('employee_onboarding')
          .update(
            onboarding.toJson(),
          )
          .eq('id',
              onboarding.onboardingId!) // Ensure you update the correct row
          .select();
      final onboardingsView = await supabaseClient
          .from('employee_onboarding_view')
          .select('*')
          .eq('is_active', true)
          .eq(
            'request_id',
            onboarding.requestId!,
          );
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq(
            'request_id',
            onboarding.requestId!,
          )
          .eq('is_active', true);
      return OnboardingViewerPageEntity(
        onboardingsView: onboardingsView
            .map((onboarding) => OnboardingsPageViewModel.fromJson(onboarding))
            .first,
        approval: approvalsView
            .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
            .toList(),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OnboardingViewerPageEntity> approveOnboarding(
      ApprovalSequenceViewModel approvalSequence,
      OnboardingsPageViewModel onboarding) async {
    try {
      final approval = await supabaseClient
          .from('approval_sequence')
          .update({
            'approver_comment': approvalSequence.approverComment,
            'approval_status': approvalSequence.approvalStatus,
            'approved_by': approvalSequence.approvedBy,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq(
              'approval_id',
              approvalSequence
                  .approvalId!) // Ensure you approve the correct row
          .select();
      final nextApproval = await supabaseClient
          .from('approval_sequence')
          .update({
            'approval_status': LookupConstants.approvalStatusApprovalPending,
          })
          .eq(
            'request_id',
            approvalSequence.requestId!,
          ) // Ensure you approve the correct row
          .eq(
            'approval_order',
            approvalSequence.approvalOrder! + 1,
          ) // Ensure you approve the correct row
          .eq(
            'approval_status',
            LookupConstants.approvalStatusApprovalQueued,
          ) // Ensure you approve the correct row
          .eq(
            'is_active',
            true,
          ) // Ensure you approve the correct row
          .select();
      if (nextApproval.isEmpty && approval.isNotEmpty) {
        await supabaseClient
            .from('requests_master')
            .update({
              'status': LookupConstants.requestStatusCompleted,
            })
            .eq(
              'request_id',
              approvalSequence.requestId!,
            )
            .select();
        final userId = await _createUserViaFunction(
          email: onboarding.email,
          password: onboarding.phone ?? '123456',
          firstNameEn: onboarding.firstNameEn,
          lastNameEn: onboarding.lastNameEn,
          phone: onboarding.phone ?? '',
          departmentId: onboarding.departmentId ?? '',
          positionId: onboarding.positionId ?? '',
        );
        await supabaseClient
            .from('users')
            .update(
              {
                'first_name_en': onboarding.firstNameEn,
                'first_name_ar': onboarding.firstNameAr,
                'last_name_en': onboarding.lastNameEn,
                'last_name_ar': onboarding.lastNameAr,
                'phone': onboarding.phone,
                'department_id': onboarding.departmentId,
                'position_id': onboarding.positionId,
                'status_id': LookupConstants.userStatusActive,
                'report_to': onboarding.reportTo,
              },
            )
            .eq('id', userId)
            .select();
      }
      final onboardingsView = await supabaseClient
          .from('employee_onboarding_view')
          .select('*')
          .eq('is_active', true)
          .eq(
            'request_id',
            approvalSequence.requestId!,
          );
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq(
            'request_id',
            onboarding.requestId!,
          )
          .eq('is_active', true);
      return OnboardingViewerPageEntity(
        onboardingsView: onboardingsView
            .map((onboarding) => OnboardingsPageViewModel.fromJson(onboarding))
            .first,
        approval: approvalsView
            .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
            .toList(),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<OnboardingsPageViewModel>> getAllOnboardingsView() async {
    try {
      final onboardings = await supabaseClient
          .from('employee_onboarding_view')
          .select('*')
          .eq('is_active', true);
      return onboardings
          .map((onboarding) => OnboardingsPageViewModel.fromJson(onboarding))
          .toList();
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
          .eq('service_id', ServicesConstants.onboardingServiceId)
          .select('*');
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<String> _createUserViaFunction({
    required String email,
    required String password,
    required String firstNameEn,
    required String lastNameEn,
    required String phone,
    required String departmentId,
    required String positionId,
  }) async {
    final response = await supabaseClient.functions.invoke(
      'create-user',
      body: {
        'email': email,
        'password': password,
        'firstNameEn': firstNameEn,
        'lastNameEn': lastNameEn,
        'phone': phone,
        'departmentId': departmentId,
        'positionId': positionId,
      },
    );

    if (response.status != 200) {
      // Handle error gracefully
      final error = response.data['error'] ?? 'Unknown error';
      throw ServerException('Create user failed: $error');
    }

    final user = response.data;
    final userId = response.data['user']?['id'];

    print('✅ User created: $user');
    return userId;
  }
}
