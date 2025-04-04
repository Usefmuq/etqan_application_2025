import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
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
            request.toJson(),
          )
          .select();
      final req = RequestMasterModel.fromJson(requestData.first);
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
          .from('onboardings')
          .insert(
            onboarding.copyWith(requestId: req.requestId).toJson(),
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
          .from('onboardings')
          .update(
            onboarding.toJson(),
          )
          .eq('id',
              onboarding.onboardingId!) // Ensure you update the correct row
          .select();
      final onboardingsView = await supabaseClient
          .from('onboardings_page_view')
          .select('*')
          .eq('request_is_active', true)
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
      }
      final onboardingsView = await supabaseClient
          .from('onboardings_page_view')
          .select('*')
          .eq('request_is_active', true)
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
          .from('onboardings_page_view')
          .select('*')
          .eq('request_is_active', true);
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
}
