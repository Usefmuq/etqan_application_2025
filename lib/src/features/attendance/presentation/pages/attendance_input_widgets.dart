import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/embedded/current_location_map.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required TextEditingController titleController,
    required TextEditingController contentController,
    required bool isWide,
    required bool isLockFieldsWithoutComment,
    List<RequestUnlockedFieldModel>? unlockedFields,
    List<ServiceField>? serviceFields,
    void Function(double lat, double lng)? onLatLng,
  }) {
    final locale = Intl.getCurrentLocale();

    final attendanceTitleField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendance_title',
    );
    final attendanceContentField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'attendance_content',
    );
    return [
      SizedBox(
        height: 300, // MUST be a fixed/bounded height
        child: CurrentLocationMap(
          followUser: true,
          onLatLng: onLatLng,
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          responsiveField(
            CustomTextFormField(
              controller: titleController,
              readOnly: !canEdit(
                attendanceTitleField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              isActive: attendanceTitleField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (attendanceTitleField?.fieldLabelAr ?? '')
                  : (attendanceTitleField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == attendanceTitleField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
          responsiveField(
            CustomTextFormField(
              controller: contentController,
              isActive: attendanceContentField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (attendanceContentField?.fieldLabelAr ?? '')
                  : (attendanceContentField?.fieldLabelEn ?? ''),
              readOnly: !canEdit(
                attendanceContentField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              maxLines: null,
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == attendanceContentField?.fieldKey,
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
