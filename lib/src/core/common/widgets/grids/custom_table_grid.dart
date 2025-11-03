import 'package:etqan_application_2025/src/core/common/entities/departments.dart';
import 'package:etqan_application_2025/src/core/common/entities/positions.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:etqan_application_2025/src/core/constants/uuid_lookup_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';

class CustomTableGrid extends StatefulWidget {
  final List<String> headers;
  final List<Map<String, dynamic>> rows;

  final bool useChipsForStatus;

  final Function(Map<String, dynamic> row)? onEdit;
  final Function(Map<String, dynamic> row)? onDelete;
  final Function(Map<String, dynamic> row)? onApprove;

  final int rowsPerPage;

  /// Pre-fetched lookup lists
  final List<Departments> departments;
  final List<UserModel> users;
  final List<Positions> positions;

  /// Row tap behavior
  final bool enableRowTap;
  final Function(Map<String, dynamic> row)? onRowPressed;

  const CustomTableGrid({
    super.key,
    required this.headers,
    required this.rows,
    this.useChipsForStatus = true,
    this.onEdit,
    this.onDelete,
    this.onApprove,
    this.rowsPerPage = 10,
    this.departments = const [],
    this.users = const [],
    this.positions = const [],
    this.enableRowTap = false,
    this.onRowPressed,
  });

  @override
  State<CustomTableGrid> createState() => _CustomTableGridState();
}

class _CustomTableGridState extends State<CustomTableGrid> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _currentPage = 0;

  late final Map<String, Map<String, String>> _deptMap; // id -> {en, ar}
  late final Map<String, Map<String, String>> _posMap; // id -> {en, ar}
  late final Map<String, Map<String, String>> _userMap; // id -> {en, ar}

  @override
  void initState() {
    super.initState();
    _deptMap = {
      for (final d in widget.departments) d.id: {'en': d.nameEn, 'ar': d.nameAr}
    };
    _posMap = {
      for (final p in widget.positions) p.id: {'en': p.nameEn, 'ar': p.nameAr}
    };
    _userMap = {
      for (final u in widget.users)
        u.id: {
          'en': '${u.firstNameEn} ${u.lastNameEn}'.trim(),
          'ar': '${u.firstNameAr} ${u.lastNameAr}'.trim(),
        }
    };
  }

  List<Map<String, dynamic>> get _pagedRows {
    final start = _currentPage * widget.rowsPerPage;
    final end = start + widget.rowsPerPage;
    return widget.rows.sublist(
      start,
      end > widget.rows.length ? widget.rows.length : end,
    );
  }

  void _sortRows(String columnKey) {
    setState(() {
      _sortAscending = !_sortAscending;
      widget.rows.sort((a, b) {
        final aVal = a[columnKey];
        final bVal = b[columnKey];
        return _sortAscending
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      });
    });
  }

  bool _isUuid(dynamic v) =>
      v is String && RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(v);

  String? _kindForKey(String columnKey) {
    final k = columnKey.toLowerCase();
    if (k.contains('department') || k.contains('القسم')) return 'dept';
    if (k.contains('position') || k.contains('الوظيفة')) return 'pos';
    if (k.contains('user') ||
        k.contains('created by') ||
        k.contains('created_by') ||
        k.contains('report to') ||
        k.contains('report_to') ||
        k.contains('المدير')) {
      return 'user';
    }
    return null;
  }

  String? _localized(
    Map<String, Map<String, String>> map,
    String id,
    String locale,
  ) {
    final o = map[id];
    if (o == null) return null;
    return (locale == 'ar' ? o['ar'] : o['en']) ?? o['en'];
  }

  Widget _formatValue(BuildContext context, String columnKey, dynamic value) {
    final locale = Localizations.localeOf(context).languageCode;

    if (value == null) return const Text('—');

    // 1) Known constants (statuses/priorities/etc.) → chip or text
    if (value is String &&
        _isUuid(value) &&
        UuidLookupConstants.combinedLookup.containsKey(value)) {
      final label = UuidLookupConstants.combinedLookup[value]?[locale] ??
          UuidLookupConstants.combinedLookup[value]?['en'] ??
          '—';
      final color = UuidLookupConstants.combinedLookup[value]?['color'] ??
          AppPallete.greyColor;

      return widget.useChipsForStatus
          ? Chip(
              label: Text(label),
              backgroundColor: color.withOpacity(0.12),
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            )
          : Text(label);
    }

    // 2) UUIDs → try department / position / user maps
    if (_isUuid(value)) {
      final kind = _kindForKey(columnKey);
      if (kind == 'dept') {
        return Text(
          _localized(_deptMap, value, locale) ?? value,
          overflow: TextOverflow.ellipsis,
        );
      }
      if (kind == 'pos') {
        return Text(
          _localized(_posMap, value, locale) ?? value,
          overflow: TextOverflow.ellipsis,
        );
      }
      if (kind == 'user') {
        return Text(
          _localized(_userMap, value, locale) ?? value,
          overflow: TextOverflow.ellipsis,
        );
      }
      return Text(value);
    }

    // 3) Booleans
    if (value is bool) return Text(value ? '✓' : '✗');

    // 4) DateTime
    if (value is DateTime) {
      return Text(DateFormat.yMMMd(locale).add_jm().format(value));
    }

    // 5) Numbers/Strings fallback
    return Text(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = widget.onEdit != null ||
        widget.onDelete != null ||
        widget.onApprove != null;

    final showArrowColumn = widget.enableRowTap;

    final dataTable = DataTable(
      showCheckboxColumn: false,
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        ...widget.headers.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          return DataColumn(
            label: InkWell(
              onTap: () {
                _sortColumnIndex = index;
                _sortRows(label);
              },
              child: Row(
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (_sortColumnIndex == index)
                    Icon(_sortAscending
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down),
                ],
              ),
            ),
          );
        }),
        if (hasActions)
          const DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (showArrowColumn)
          const DataColumn(
            label: SizedBox.shrink(), // arrow column header
          ),
      ],
      rows: _pagedRows.map((row) {
        return DataRow(
          color: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.grey.withOpacity(0.06); // full-row hover tint
            }
            return null;
          }),
          onSelectChanged: (widget.enableRowTap && widget.onRowPressed != null)
              ? (_) => widget.onRowPressed!(row) // row-wide tap
              : null,
          cells: [
            ...widget.headers.map(
              (key) => DataCell(_formatValue(context, key, row[key])),
            ),
            if (hasActions)
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Edit',
                        onPressed: () => widget.onEdit!(row),
                      ),
                    if (widget.onApprove != null)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        tooltip: 'Approve',
                        onPressed: () => widget.onApprove!(row),
                      ),
                    if (widget.onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'Delete',
                        onPressed: () => widget.onDelete!(row),
                      ),
                  ],
                ),
              ),
            if (showArrowColumn)
              const DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.chevron_right,
                      size: 18, color: AppPallete.greyColor),
                ),
              ),
          ],
        );
      }).toList(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 600,
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTableTheme(
                        data: DataTableThemeData(
                          dataRowColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.grey.withOpacity(0.06);
                            }
                            return null;
                          }),
                        ),
                        child: dataTable,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Page ${_currentPage + 1} of ${(widget.rows.length / widget.rowsPerPage).ceil()}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: (_currentPage + 1) * widget.rowsPerPage <
                                  widget.rows.length
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
