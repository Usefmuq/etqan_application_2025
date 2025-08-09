import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_model.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<ApprovalSequenceModel> mapServiceApproversToApprovalSequence({
  required int requestId,
  required List<ServiceApprovalUsersModel> serviceApprovers,
}) {
  return serviceApprovers.map((approver) {
    return ApprovalSequenceModel(
      // approvalId: 0, // Let database handle auto-increment
      requestId: requestId,
      roleId: approver.roleId,
      approverUserId: approver.approverUserId,
      approvalStatus: approver.approvalOrder == 1
          ? LookupConstants.approvalStatusApprovalPending
          : LookupConstants.approvalStatusApprovalQueued,
      approverComment: null,
      approvalOrder: approver.approvalOrder,
      approvedAt: null,
      isActive: approver.isActive,
      createdAt: DateTime.now(),
    );
  }).toList();
}

Future<List<RequestUnlockedFieldModel>?> fetchUnlockedFields(
    int requestId) async {
  final response = await Supabase.instance.client
      .from('request_unlocked_fields')
      .select()
      .eq('request_id', requestId)
      .eq('is_active', true);

  final data = response as List;
  return data.map((json) => RequestUnlockedFieldModel.fromJson(json)).toList();
}

Future<bool> updateApprovalSequenceDS({
  required ApprovalSequenceViewModel approvalSequence,
  List<RequestUnlockedFieldModel>? requestUnlockedFields,
  required SupabaseClient supabaseClient,
}) async {
  final approval = await supabaseClient
      .from('approval_sequence')
      .update({
        'approver_comment': approvalSequence.approverComment,
        'approval_status': approvalSequence.approvalStatus,
        'approved_by': approvalSequence.approvedBy,
        'approved_at': DateTime.now().toIso8601String(),
      })
      .eq('approval_id',
          approvalSequence.approvalId!) // Ensure you approve the correct row
      .select();
// ---------- #1 Approved Case ---------------
  if (approvalSequence.approvalStatus ==
      LookupConstants.approvalStatusApprovalApproved) {
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
  }

  // ---------- #2 Reject Case ---------------
  if (approvalSequence.approvalStatus ==
      LookupConstants.approvalStatusApprovalRejected) {
    await supabaseClient
        .from('requests_master')
        .update({
          'status': LookupConstants.requestStatusRejected,
        })
        .eq(
          'request_id',
          approvalSequence.requestId!,
        )
        .select();
  }

  // ---------- #3 Return Case ---------------
  if (approvalSequence.approvalStatus ==
      LookupConstants.approvalStatusApprovalReturnForCorrection) {
    await supabaseClient
        .from('requests_master')
        .update({
          'status': LookupConstants.requestStatusReturnForCorrection,
        })
        .eq(
          'request_id',
          approvalSequence.requestId!,
        )
        .select();
    if (requestUnlockedFields != null) {
      await supabaseClient
          .from('request_unlocked_fields')
          .insert(requestUnlockedFields.map((e) => e.toJson()).toList())
          .select();
    }
  }

  return true;
}

extension ApprovalSequenceRowFormatter on ApprovalSequence {
  Map<String, dynamic> toTableRow() {
    return {
      'Approver ID': approverUserId ?? '—',
      'Role ID': roleId ?? '—',
      'Status': approvalStatus,
      'Comment': approverComment ?? '',
      'Approved At': approvedAt,
      'Order': approvalOrder,
      'Created At': createdAt,
    };
  }
}
