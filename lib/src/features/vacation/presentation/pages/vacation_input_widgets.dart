import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_date_picker.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_double_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_dropdown_list.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/constants/uuid_lookup_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VacationInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required String? vacationTypeId,
    required ValueChanged<String?> onVacationTypeChanged,
    required DateTime? startDate,
    required ValueChanged<DateTime> onStartDateChanged,
    required TextEditingController reason,
    required DateTime? endDate,
    required ValueChanged<DateTime> onEndDateChanged,
    required double? daysCount,
    required bool isWide,
    required bool isLockFieldsWithoutComment,
    List<RequestUnlockedFieldModel>? unlockedFields,
    List<ServiceField>? serviceFields,
  }) {
    final locale = Intl.getCurrentLocale();

    final vacationReasonField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'vacation_reason',
    );

    final vacationTypeIdField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'vacation_vacationTypeId',
    );

    final startDateField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'vacation_startDate',
    );

    final endDateField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'vacation_endDate',
    );

    final daysCountField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'vacation_daysCount',
    );
    return [
      const SizedBox(height: 20),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          responsiveField(
            CustomDropdownList<String>(
              label: locale == 'ar'
                  ? (vacationTypeIdField?.fieldLabelAr ?? '')
                  : (vacationTypeIdField?.fieldLabelEn ?? ''),
              selectedItem: vacationTypeId,
              items: UuidLookupConstants.vacationTypeMap.keys.toList(),
              getLabel: (String id) {
                return UuidLookupConstants.combinedLookup[id]
                        ?[locale == 'ar' ? 'ar' : 'en'] as String? ??
                    '';
              },
              onChanged: onVacationTypeChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return locale == 'ar' ? 'مطلوب' : 'Required';
                }
                return null;
              },
              readOnly: !canEdit(
                vacationTypeIdField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              isActive: vacationTypeIdField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (vacationTypeIdField?.fieldLabelAr ?? '')
                  : (vacationTypeIdField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == vacationTypeIdField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
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
              validator: (val) =>
                  val == null ? startDateField?.fieldLabelAr : null,
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
            CustomDoubleFormField(
              key: ValueKey(daysCount),
              initialValue: daysCount,
              readOnly: true,
              isActive: daysCountField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (daysCountField?.fieldLabelAr ?? '')
                  : (daysCountField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == daysCountField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
          responsiveField(
            CustomTextFormField(
              controller: reason,
              readOnly: !canEdit(
                vacationReasonField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              isActive: vacationReasonField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (vacationReasonField?.fieldLabelAr ?? '')
                  : (vacationReasonField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == vacationReasonField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
        ],
      ),
    ];
  }
}
