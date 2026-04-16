import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_date_picker.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_dropdown_list.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_switch_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceRegularizationInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required TextEditingController reasonController,
    required DateTime? startDate,
    required ValueChanged<DateTime> onStartDateChanged,
    required DateTime? endDate,
    required ValueChanged<DateTime> onEndDateChanged,
    required ValueChanged<bool> onChangedIncludeWeekends,
    required ValueChanged<String?> onProposedCheckInChanged,
    required ValueChanged<String?> onProposedCheckOutChanged,
    required bool includeWeekends,
    required String? proposedCheckIn,
    required String? proposedCheckOut,
    required bool isWide,
    required bool isLockFieldsWithoutComment,
    List<RequestUnlockedFieldModel>? unlockedFields,
    List<ServiceField>? serviceFields,
  }) {
    final locale = Intl.getCurrentLocale();

    final attendanceReasonField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendanceRegularization_reason',
    );

    final startDateField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendanceRegularization_startDate',
    );

    final endDateField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendanceRegularization_endDate',
    );

    final includeWeekendsField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendanceRegularization_includeWeekends',
    );

    final proposedCheckInField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendanceRegularization_proposedCheckIn',
    );

    final proposedCheckOutField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendanceRegularization_proposedCheckOut',
    );

    return [
      const SizedBox(height: 20),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          responsiveField(
            CustomTextFormField(
              controller: reasonController,
              readOnly: !canEdit(
                attendanceReasonField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              isActive: attendanceReasonField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (attendanceReasonField?.fieldLabelAr ?? '')
                  : (attendanceReasonField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == attendanceReasonField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
        ],
      ),
      responsiveField(
        CustomDatePicker(
          selectedDate: startDate,
          onChanged: onStartDateChanged,
          readOnly: !canEdit(
            startDateField?.fieldKey ?? '',
            isLockFieldsWithoutComment,
            unlockedFields,
          ),
          validator: (val) => val == null ? startDateField?.fieldLabelAr : null,
          isActive: startDateField?.isActive ?? false,
          label: locale == 'ar'
              ? (startDateField?.fieldLabelAr ?? '')
              : (startDateField?.fieldLabelEn ?? ''),
          reviewerComment: unlockedFields
              ?.firstWhereOrNull(
                (e) => e.fieldKey == startDateField?.fieldKey,
              )
              ?.reason,
        ),
        isWide,
      ),
      responsiveField(
        CustomDatePicker(
          selectedDate: endDate,
          onChanged: onEndDateChanged,
          readOnly: !canEdit(
            endDateField?.fieldKey ?? '',
            isLockFieldsWithoutComment,
            unlockedFields,
          ),
          isActive: endDateField?.isActive ?? false,
          label: locale == 'ar'
              ? (endDateField?.fieldLabelAr ?? '')
              : (endDateField?.fieldLabelEn ?? ''),
          reviewerComment: unlockedFields
              ?.firstWhereOrNull(
                (e) => e.fieldKey == endDateField?.fieldKey,
              )
              ?.reason,
        ),
        isWide,
      ),
      responsiveField(
        CustomDropdownList<String>(
          label: locale == 'ar'
              ? (proposedCheckInField?.fieldLabelAr ?? '')
              : (proposedCheckInField?.fieldLabelEn ?? ''),
          selectedItem: proposedCheckIn,
          items: generateTimeValues(),
          getLabel: (String value) {
            return formatTimeForDisplay(value, locale);
          },
          onChanged: onProposedCheckInChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return locale == 'ar' ? 'مطلوب' : 'Required';
            }
            return null;
          },
          readOnly: !canEdit(
            proposedCheckInField?.fieldKey ?? '',
            isLockFieldsWithoutComment,
            unlockedFields,
          ),
          isActive: proposedCheckInField?.isActive ?? false,
          hintText: locale == 'ar'
              ? (proposedCheckInField?.fieldLabelAr ?? '')
              : (proposedCheckInField?.fieldLabelEn ?? ''),
          reviewerComment: unlockedFields
              ?.firstWhereOrNull(
                (e) => e.fieldKey == proposedCheckInField?.fieldKey,
              )
              ?.reason,
        ),
        isWide,
      ),
      responsiveField(
        CustomDropdownList<String>(
          label: locale == 'ar'
              ? (proposedCheckOutField?.fieldLabelAr ?? '')
              : (proposedCheckOutField?.fieldLabelEn ?? ''),
          selectedItem: proposedCheckOut,
          items: generateTimeValues(),
          getLabel: (String value) {
            return formatTimeForDisplay(value, locale);
          },
          onChanged: onProposedCheckOutChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return locale == 'ar' ? 'مطلوب' : 'Required';
            }
            return null;
          },
          readOnly: !canEdit(
            proposedCheckOutField?.fieldKey ?? '',
            isLockFieldsWithoutComment,
            unlockedFields,
          ),
          isActive: proposedCheckOutField?.isActive ?? false,
          hintText: locale == 'ar'
              ? (proposedCheckOutField?.fieldLabelAr ?? '')
              : (proposedCheckOutField?.fieldLabelEn ?? ''),
          reviewerComment: unlockedFields
              ?.firstWhereOrNull(
                (e) => e.fieldKey == proposedCheckOutField?.fieldKey,
              )
              ?.reason,
        ),
        isWide,
      ),
      responsiveField(
        CustomSwitchField(
          value: includeWeekends,
          onChanged: onChangedIncludeWeekends,
          readOnly: !canEdit(
            includeWeekendsField?.fieldKey ?? '',
            isLockFieldsWithoutComment,
            unlockedFields,
          ),
          isActive: includeWeekendsField?.isActive ?? false,
          title: locale == 'ar'
              ? (includeWeekendsField?.fieldLabelAr ?? '')
              : (includeWeekendsField?.fieldLabelEn ?? ''),
          reviewerComment: unlockedFields
              ?.firstWhereOrNull(
                (e) => e.fieldKey == includeWeekendsField?.fieldKey,
              )
              ?.reason,
        ),
        isWide,
      ),
    ];
  }
}
