import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class BlogInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required List<String> selectedTopics,
    required void Function(String topic) onToggleTopic, // ✅ Added callback
    required TextEditingController titleController,
    required TextEditingController contentController,
    required bool isWide,
    required bool isUpdate,
    List<RequestUnlockedFieldModel>? unlockedFields,
  }) {
    bool containsKey(String key) {
      return unlockedFields?.any((element) => element.fieldKey == key) ?? false;
    }

    return [
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          'Option 1',
          'Option 2',
          'Option 3',
          'Option 4',
          'Option 5',
        ].map((topic) {
          final isSelected = selectedTopics.contains(topic);
          return GestureDetector(
            onTap: () {
              if (isUpdate && !containsKey('blog_topics')) {
                return;
              }
              onToggleTopic(topic);
            },
            child: Chip(
              label: Text(topic, style: const TextStyle(fontSize: 15)),
              color: isSelected
                  ? const WidgetStatePropertyAll(AppPallete.gradient1)
                  : null,
              side: isSelected
                  ? null
                  : const BorderSide(color: AppPallete.borderColor),
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
              readOnly: isUpdate ? !containsKey('blog_title') : false,
              hintText: 'Blog title',
            ),
            isWide,
          ),
          responsiveField(
            CustomTextFormField(
              controller: contentController,
              hintText: 'Blog content',
              readOnly: isUpdate ? !containsKey('blog_content') : false,
              maxLines: null,
            ),
            isWide,
          ),
        ],
      ),
    ];
  }
}
