import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_model.dart';
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

  Future<List<RequestUnlockedFieldModel>> fetchUnlockedFields(
      int requestId) async {
    final response = await Supabase.instance.client
        .from('request_unlocked_fields')
        .select()
        .eq('request_id', requestId);

    final data = response as List;
    return data
        .map((json) => RequestUnlockedFieldModel.fromJson(json))
        .toList();
  }
}
