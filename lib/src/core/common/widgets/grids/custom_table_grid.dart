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

  const CustomTableGrid({
    super.key,
    required this.headers,
    required this.rows,
    this.useChipsForStatus = true,
    this.onEdit,
    this.onDelete,
    this.onApprove,
    this.rowsPerPage = 10,
  });

  @override
  State<CustomTableGrid> createState() => _CustomTableGridState();
}

class _CustomTableGridState extends State<CustomTableGrid> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _currentPage = 0;

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

  Widget formatValue(BuildContext context, dynamic value) {
    final locale = Localizations.localeOf(context).languageCode;

    if (value == null) return const Text('—');

    // UUID -> Lookup label + color (status, user, role)
    if (value is String &&
        RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(value) &&
        UuidLookupConstants.combinedLookup.containsKey(value)) {
      final label = UuidLookupConstants.combinedLookup[value]?[locale] ?? '—';
      final color = UuidLookupConstants.combinedLookup[value]?['color'] ??
          AppPallete.greyColor;

      return widget.useChipsForStatus
          ? Chip(
              label: Text(label),
              backgroundColor: color.withOpacity(0.12),
              labelStyle: TextStyle(
                // color: color,
                fontWeight: FontWeight.w500,
              ),
            )
          : Text(label);
    }

    // Booleans
    if (value is bool) return Text(value ? '✓' : '✗');

    // DateTime
    if (value is DateTime) {
      return Text(DateFormat.yMMMd(locale).add_jm().format(value));
    }

    return Text(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = widget.onEdit != null ||
        widget.onDelete != null ||
        widget.onApprove != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 500, // ✅ Give a max height to avoid infinite size
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingRowColor:
                            WidgetStateProperty.all(Colors.grey.shade100),
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
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
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
                              label: Text('Actions',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                        ],
                        rows: _pagedRows.map((row) {
                          return DataRow(
                            cells: [
                              ...widget.headers.map((key) =>
                                  DataCell(formatValue(context, row[key]))),
                              if (hasActions)
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.onEdit != null)
                                        IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 18),
                                          tooltip: 'Edit',
                                          onPressed: () => widget.onEdit!(row),
                                        ),
                                      if (widget.onApprove != null)
                                        IconButton(
                                          icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 18),
                                          tooltip: 'Approve',
                                          onPressed: () =>
                                              widget.onApprove!(row),
                                        ),
                                      if (widget.onDelete != null)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 18),
                                          tooltip: 'Delete',
                                          onPressed: () =>
                                              widget.onDelete!(row),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
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
