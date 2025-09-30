import 'package:etqan_application_2025/src/core/data/models/role_permission_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';

class RoleCard extends StatelessWidget {
  final String roleId;
  final String roleName;

  /// Option A: pass PermissionsView list (original behavior)
  final List<PermissionsView>? permissions;

  /// Option B: pass RolePermissionViewModel list (NEW)
  final List<RolePermissionViewModel>? rolePermissions;

  final bool useAr;
  final Map<String, String>? departmentNames;

  const RoleCard({
    super.key,
    required this.roleId,
    required this.roleName,
    required this.useAr,
    this.departmentNames,
    this.permissions,
    this.rolePermissions,
  }) : assert(
          (permissions != null) ^ (rolePermissions != null),
          'Pass EITHER `permissions` OR `rolePermissions`, not both.',
        );

  @override
  Widget build(BuildContext context) {
    // Normalize to List<PermissionsView> so the rest of your code stays unchanged
    final List<PermissionsView> effectivePermissions =
        permissions ?? _mapFromRolePermissionList(rolePermissions!);

    final theme = Theme.of(context);
    final bundle = _collapseBundle(effectivePermissions);

    final scopeText = bundle.allDepartments
        ? (useAr ? 'كل الأقسام' : 'All Departments')
        : (departmentNames?[bundle.departmentId] ??
            bundle.departmentId ??
            (useAr ? 'قسم غير معروف' : 'Unknown Department'));

    final now = DateTime.now();
    final end = bundle.endDate;
    final statusChip = end == null
        ? _StatusChip(
            label: useAr ? 'مفتوح' : 'Open',
            color: theme.colorScheme.secondaryContainer,
            textColor: theme.colorScheme.onSecondaryContainer,
          )
        : (end.isBefore(now)
            ? _StatusChip(
                label: useAr ? 'منتهي' : 'Expired',
                color: theme.colorScheme.errorContainer,
                textColor: theme.colorScheme.onErrorContainer,
              )
            : _StatusChip(
                label: useAr
                    ? 'ينتهي في ${DateFormat.yMMMd('ar').format(end)}'
                    : 'Ends ${DateFormat.yMMMd().format(end)}',
                color: theme.colorScheme.primaryContainer,
                textColor: theme.colorScheme.onPrimaryContainer,
              ));

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment:
              useAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Role header row
            Row(
              children: [
                _RoleIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    roleName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                statusChip,
              ],
            ),
            const SizedBox(height: 6),
            // Scope row
            Row(
              children: [
                Icon(Icons.apartment, size: 18, color: theme.hintColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    scopeText,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Permissions list (unchanged)
            _PermissionSection(
              permissions: effectivePermissions,
              useAr: useAr,
            ),
          ],
        ),
      ),
    );
  }

  /// Map RolePermissionViewModel → PermissionsView with safe defaults
  List<PermissionsView> _mapFromRolePermissionList(
      List<RolePermissionViewModel> list) {
    return list.map((r) {
      return PermissionsView(
        userId: '', // not available on the role-permission view
        fullNameEn: '',
        fullNameAr: '',
        email: '',
        roleId: r.roleId,
        roleNameEn: r.roleNameEn,
        roleNameAr: r.roleNameAr,
        permissionId: r.permissionId,
        permissionKey: r.permissionKey,
        permissionDescriptionEn: r.permissionDescriptionEn,
        permissionDescriptionAr: r.permissionDescriptionAr,
        departmentId: null, // default (not on view)
        allDepartments: true, // default (not on view)
        endDate: null, // default (not on view)
      );
    }).toList();
  }

  /// Consolidates flags across permission rows for the same role.
  RoleBundle _collapseBundle(List<PermissionsView> rows) {
    bool allDepts = rows.every((r) => r.allDepartments);
    String? deptId = rows
        .firstWhere((r) => !r.allDepartments, orElse: () => rows.first)
        .departmentId;
    DateTime? maxEnd = rows
        .where((r) => r.endDate != null)
        .map((r) => r.endDate!)
        .fold<DateTime?>(
            null, (p, c) => p == null ? c : (c.isAfter(p) ? c : p));
    return RoleBundle(
      roleId: rows.first.roleId,
      roleNameEn: rows.first.roleNameEn,
      roleNameAr: rows.first.roleNameAr,
      allDepartments: allDepts,
      departmentId: deptId,
      endDate: maxEnd,
    );
  }
}

class RoleBundle {
  final String roleId;
  final String roleNameEn;
  final String roleNameAr;
  bool allDepartments;
  String? departmentId;
  DateTime? endDate;

  RoleBundle({
    required this.roleId,
    required this.roleNameEn,
    required this.roleNameAr,
    required this.allDepartments,
    this.departmentId,
    this.endDate,
  });
}

class _RoleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
      child: Icon(
        Icons.verified_user,
        size: 18,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: TextStyle(color: textColor)),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class _PermissionSection extends StatelessWidget {
  final List<PermissionsView> permissions;
  final bool useAr;

  const _PermissionSection({
    required this.permissions,
    required this.useAr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          useAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment:
                useAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: permissions.map((p) {
              final desc =
                  useAr ? p.permissionDescriptionAr : p.permissionDescriptionEn;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        desc,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
