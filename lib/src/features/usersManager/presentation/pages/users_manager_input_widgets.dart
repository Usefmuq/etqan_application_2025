import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_multi_checkbox.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/data/models/role_permission_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/roles_model.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/pages/role_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersManagerInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required List<PermissionsView> permissionsView,
    required List<RolesModel> allRoles,
    required List<RolesModel> selectedRoles,
    required TextEditingController titleController,
    required TextEditingController contentController,
    required bool isWide,
    required bool isLockFieldsWithoutComment,
    List<RequestUnlockedFieldModel>? unlockedFields,
    List<ServiceField>? serviceFields,
    required List<RolePermissionViewModel> rolePermissionView,
  }) {
    final locale = Intl.getCurrentLocale();
    final byRole = _groupByRole(permissionsView);

    final usersManagerTitleField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'usersManager_title',
    );
    final usersManagerContentField = serviceFields?.firstWhereOrNull(
      (field) => field.fieldKey == 'usersManager_content',
    );
    return [
      ...byRole.entries.map(
        (e) => RoleCard(
          roleId: e.key,
          roleName: locale == 'ar' ? e.value.roleNameAr : e.value.roleNameEn,
          permissions: e.value.permissions,
          useAr: locale == 'ar',
          departmentNames: null,
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
                usersManagerTitleField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              isActive: usersManagerTitleField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (usersManagerTitleField?.fieldLabelAr ?? '')
                  : (usersManagerTitleField?.fieldLabelEn ?? ''),
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == usersManagerTitleField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
          responsiveField(
            CustomMultiCheckbox<RolesModel>(
              title: 'الأدوار',
              items: allRoles,
              selectedItems: selectedRoles,
              itemLabel: (r) => locale == 'ar' ? r.roleNameAr : r.roleNameEn,
              itemId: (r) => r.roleId,
              pageSize: 8,
              searchHint: locale == 'ar' ? 'ابحث…' : 'Search…',
              onChanged: (list) async {
                final newSelected = List<RolesModel>.from(list);
                final roleIds = newSelected.map((r) => r.roleId).toList();
                final fetched = await fetchRolePermissionView(roleIds);

                setState(() {
                  selectedRoles
                    ..clear()
                    ..addAll(newSelected);

                  // ✅ mutate the same object instead of reassigning the parameter
                  rolePermissionView
                    ..clear()
                    ..addAll(fetched);
                });
              },
              // Optional trailing
              trailingBuilder: (r) => const Icon(Icons.verified_user, size: 16),
            ),
            isWide,
          ),
          if ((rolePermissionView?.isNotEmpty ?? false)) ...[
            // One card per distinct role
            ...rolePermissionView!
                .map((e) => e.roleId)
                .toSet() // distinct roleIds
                .map((rid) {
              final perRole =
                  rolePermissionView!.where((r) => r.roleId == rid).toList();
              print(rolePermissionView?.length);
              final roleName = locale == 'ar'
                  ? perRole.first.roleNameAr
                  : perRole.first.roleNameEn;

              return RoleCard(
                roleId: rid,
                roleName: roleName,
                rolePermissions: perRole, // ✅ only this role’s rows
                useAr: locale == 'ar',
                departmentNames: null,
              );
            }),
          ],
          responsiveField(
            CustomTextFormField(
              controller: contentController,
              isActive: usersManagerContentField?.isActive ?? false,
              hintText: locale == 'ar'
                  ? (usersManagerContentField?.fieldLabelAr ?? '')
                  : (usersManagerContentField?.fieldLabelEn ?? ''),
              readOnly: !canEdit(
                usersManagerContentField?.fieldKey ?? '',
                isLockFieldsWithoutComment,
                unlockedFields,
              ),
              maxLines: null,
              reviewerComment: unlockedFields
                  ?.firstWhereOrNull(
                    (e) => e.fieldKey == usersManagerContentField?.fieldKey,
                  )
                  ?.reason,
            ),
            isWide,
          ),
        ],
      ),
    ];
  }

  /// Groups rows by roleId, collecting permissions.
  static Map<String, RoleBundle> _groupByRole(List<PermissionsView> rows) {
    final map = <String, RoleBundle>{};
    for (final r in rows) {
      final bundle = map.putIfAbsent(
        r.roleId,
        () => RoleBundle(
          roleId: r.roleId,
          roleNameEn: r.roleNameEn,
          roleNameAr: r.roleNameAr,
          allDepartments: r.allDepartments,
          departmentId: r.departmentId,
          endDate: r.endDate,
        ),
      );
      bundle.permissions.add(r);
      // Keep latest endDate if multiple
      if (r.endDate != null) {
        if (bundle.endDate == null || r.endDate!.isAfter(bundle.endDate!)) {
          bundle.endDate = r.endDate;
        }
      }
      // If any row says allDepartments=false, keep specific deptId
      if (!r.allDepartments && r.departmentId != null) {
        bundle.allDepartments = false;
        bundle.departmentId = r.departmentId;
      }
    }
    return map;
  }
}

class RoleBundle {
  final String roleId;
  final String roleNameEn;
  final String roleNameAr;
  bool allDepartments;
  String? departmentId;
  DateTime? endDate;
  final List<PermissionsView> permissions;

  RoleBundle({
    required this.roleId,
    required this.roleNameEn,
    required this.roleNameAr,
    required this.allDepartments,
    required this.departmentId,
    required this.endDate,
  }) : permissions = [];
}
