import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required List<String> selectedTopics,
    required TextEditingController titleController,
    required TextEditingController contentController,
    required bool isWide,
    required bool isLockFieldsWithoutComment,
    List<RequestUnlockedFieldModel>? unlockedFields,
    List<ServiceField>? serviceFields,

    // NEW: pass available topics from caller instead of hard-coding
    List<String> topics = const [
      'Option 1',
      'Option 2',
      'Option 3',
      'Option 4',
      'Option 5'
    ],
  }) {
    final locale = Intl.getCurrentLocale();

    final blogTitleField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'blog_title',
    );
    final blogContentField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'blog_content',
    );
    return [
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: topics.map((topic) {
          final isSelected = selectedTopics.contains(topic);
          return GestureDetector(
            onTap: () {
              // lock topics if blog_topics not unlocked in correction mode
              if (isLockFieldsWithoutComment &&
                  !containsKey(
                    'blog_topics',
                    unlockedFields,
                  )) {
                return;
              }
              setState(() {
                isSelected
                    ? selectedTopics.remove(topic)
                    : selectedTopics.add(topic);
              });
            },
            child: Chip(
              label: Text(topic, style: const TextStyle(fontSize: 15)),
              // Use backgroundColor for wider SDK compatibility
              backgroundColor: isSelected ? AppPallete.gradient1 : null,
              shape: isSelected
                  ? const StadiumBorder()
                  : const StadiumBorder(
                      side: BorderSide(color: AppPallete.borderColor)),
            ),
          );
        }).toList(),
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
                blogTitleField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              isActive: blogTitleField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (blogTitleField?.fieldLabelAr ?? '')
                  : (blogTitleField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == blogTitleField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
          responsiveField(
            CustomTextFormField(
              controller: contentController,
              isActive: blogContentField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (blogContentField?.fieldLabelAr ?? '')
                  : (blogContentField?.fieldLabelEn ?? ''),
              readOnly: !canEdit(
                blogContentField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              maxLines: null,
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == blogContentField?.fieldKey,
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
