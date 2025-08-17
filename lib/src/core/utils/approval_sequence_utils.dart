import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_model.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

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

Widget buildApprovalTableSection(
  BuildContext context,
  BlogViewerPageEntity? blogViewerPage,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(title: AppLocalizations.of(context)!.approvalSequence),
      CustomTableGrid(
        headers: [
          AppLocalizations.of(context)!.approvalId,
          AppLocalizations.of(context)!.requestId,
          AppLocalizations.of(context)!.approvalStatus,
          AppLocalizations.of(context)!.approverName,
          AppLocalizations.of(context)!.roleName,
          AppLocalizations.of(context)!.approvedAt,
          AppLocalizations.of(context)!.createdAt,
        ],
        rows: blogViewerPage!.approval!.map((e) => e.toTableRow()).toList(),
        useChipsForStatus: true,
      ),
    ],
  );
}

Widget buildCommentField(
  BuildContext context,
  TextEditingController commentController,
) {
  return CustomTextFormField(
    controller: commentController,
    hintText: AppLocalizations.of(context)!.approvalComment,
    maxLines: null,
    readOnly: false,
    required: true,
  );
}

Widget buildReturnForCorrectionUI(
  BuildContext context,
  List<ServiceField> serviceFields,
  Map<int, bool> unlockedFieldsReadOnly,
  List<TextEditingController> fieldControllers,
  void Function(int index, bool wasReadOnly) onToggle, // <-- new
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(
        title: AppLocalizations.of(context)!.returnForCorrection,
      ),
      const SizedBox(height: 8),
      Column(
        children: serviceFields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          final isReadOnly = unlockedFieldsReadOnly[index] ?? true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: IconButton(
                    onPressed: () => onToggle(index, isReadOnly), // <-- per row
                    icon: Icon(isReadOnly ? Icons.lock : Icons.lock_open),
                    color: isReadOnly ? Colors.grey : Colors.red,
                  ),
                ),
                Expanded(
                  child: CustomTextFormField(
                    controller: fieldControllers[index],
                    hintText: field.fieldLabelAr ?? field.fieldLabelEn,
                    readOnly: isReadOnly,
                    required: !isReadOnly,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

bool hasAnyUnlockedField(
  final Map<int, bool> unlockedFieldsReadOnly,
) {
  // false = unlocked (editable)
  return unlockedFieldsReadOnly.values.any((v) => v == false);
}

// ---------------------------
// UI: Action Buttons
// ---------------------------
Widget buildActionButtons({
  required BuildContext context,
  required VoidCallback onApprove,
  required VoidCallback onReturnForCorrection,
  required VoidCallback onReject,
  required Map<int, bool> unlockedFieldsReadOnly,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;

      final approve = CustomButton(
        text: AppLocalizations.of(context)!.approve,
        icon: Icons.check_circle_outline,
        onPressed: onApprove,
      );

      final returnForCorrection = CustomButton(
        text: AppLocalizations.of(context)!.returnForCorrection,
        icon: Icons.cancel_outlined,
        backgroundColor: AppPallete.textSecondary,
        isDisabled: !hasAnyUnlockedField(unlockedFieldsReadOnly),
        onPressed: onReturnForCorrection,
      );

      final reject = CustomButton(
        text: AppLocalizations.of(context)!.reject,
        icon: Icons.cancel_outlined,
        backgroundColor: AppPallete.errorColor,
        onPressed: onReject,
      );

      if (isSmall) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            approve,
            const SizedBox(height: 12),
            returnForCorrection,
            const SizedBox(height: 12),
            reject,
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: approve),
          const SizedBox(width: 12),
          Expanded(child: returnForCorrection),
          const SizedBox(width: 12),
          Expanded(child: reject),
        ],
      );
    },
  );
}

// ---------------------------
// Logic: Return For Correction
// ---------------------------
Future<void> handleReturnForCorrectionPressed({
  required BuildContext context,
  required int requestId,
  required void Function(List<RequestUnlockedFieldModel>) onReturnForCorrection,
  required GlobalKey<FormState> formKey,
  required List<RequestUnlockedFieldModel> requestUnlockedFields,
  required Map<int, bool> unlockedFieldsReadOnly,
  required List<ServiceField> serviceFields,
  required List<TextEditingController> fieldControllers,
}) async {
  final ok = formKey.currentState?.validate() ?? false;
  if (!ok) {
    SmartNotifier.warning(
      context,
      title: AppLocalizations.of(context)!.error,
      message: AppLocalizations.of(context)!.fieldIsRequired,
    );
    return;
  }

  requestUnlockedFields = [];
  for (final entry in unlockedFieldsReadOnly.entries) {
    final index = entry.key;
    final isReadOnly = entry.value;

    if (isReadOnly == false) {
      final reason = fieldControllers[index].text.trim();
      final field = serviceFields[index];

      if (reason.isEmpty) {
        continue; // validator should already show red error
      }

      requestUnlockedFields.add(
        RequestUnlockedFieldModel(
          id: const Uuid().v1(),
          fieldKey: field.fieldKey,
          requestId: requestId,
          unlockedBy:
              (context.read<AppUserCubit>().state as AppUserSignedIn).user.id,
          unlockedAt: DateTime.now(),
          reason: reason,
          isActive: true,
        ),
      );
    }
  }

  if (requestUnlockedFields.isEmpty) {
    SmartNotifier.warning(
      context,
      title: AppLocalizations.of(context)!.error,
      message: AppLocalizations.of(context)!.fieldIsRequired,
    );
    return;
  }

  onReturnForCorrection(requestUnlockedFields);
}

// ---------------------------
// Logic: Approve / Reject
// ---------------------------
Future<void> approveRequest({
  required BuildContext context,
  required bool isApproved,
  required ApprovalSequenceViewModel pendingApproval,
  required dynamic model, // blogModel, serviceModel, etc.
  required GlobalKey<FormState> formKey,
  required TextEditingController commentController,
  List<RequestUnlockedFieldModel>? requestUnlockedFields,
  required void Function(dynamic event) dispatchEvent, // pass bloc.add
  required dynamic Function({
    required ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required dynamic model,
  }) buildEvent, // factory to build the event
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        isApproved
            ? AppLocalizations.of(context)!.confirmApproval
            : (requestUnlockedFields.isNullOrEmpty
                ? AppLocalizations.of(context)!.confirmRejection
                : AppLocalizations.of(context)!.confirmReturnForCorrection),
      ),
      content: Text(
        isApproved
            ? AppLocalizations.of(context)!.confirmApprovalDesc
            : (requestUnlockedFields.isNullOrEmpty
                ? AppLocalizations.of(context)!.confirmRejectionDesc
                : AppLocalizations.of(context)!.confirmReturnForCorrectionDesc),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(AppLocalizations.of(context)!.yes),
        ),
      ],
    ),
  );
  if (!context.mounted || confirmed != true) return;

  final userId =
      (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

  if (!(formKey.currentState?.validate() ?? false)) {
    SmartNotifier.warning(
      context,
      title: AppLocalizations.of(context)!.error,
      message: AppLocalizations.of(context)!.fieldIsRequired,
    );
    return;
  }

  final updatedApproval = pendingApproval.copyWith(
    approvalStatus: isApproved
        ? LookupConstants.approvalStatusApprovalApproved
        : (requestUnlockedFields.isNullOrEmpty
            ? LookupConstants.approvalStatusApprovalRejected
            : LookupConstants.approvalStatusApprovalReturnForCorrection),
    approverComment: commentController.text,
    approvedBy: userId,
  );

  dispatchEvent(
    buildEvent(
      approvalSequence: updatedApproval,
      requestUnlockedFields: requestUnlockedFields,
      model: model,
    ),
  );
}
