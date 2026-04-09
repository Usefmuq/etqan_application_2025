import 'dart:math' as math;
import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/fetch_reports_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pluto_grid/pluto_grid.dart';

class ReportsViewerPage extends StatefulWidget {
  final ReportsViewerPageEntity? initialReportsViewerPage;
  final String? reportId;

  const ReportsViewerPage({
    super.key,
    this.initialReportsViewerPage,
    this.reportId,
  });

  static route(ReportsViewerPageEntity? reportsViewerPage) => MaterialPageRoute(
        builder: (context) => ReportsViewerPage(
          initialReportsViewerPage: reportsViewerPage,
        ),
      );

  @override
  State<ReportsViewerPage> createState() => _ReportsViewerPageState();
}

class _ReportsViewerPageState extends State<ReportsViewerPage> {
  ReportsViewerPageEntity? reportsViewerPage;
  bool isLoading = true;
  Key gridKey = UniqueKey();

  late final PlutoGridStateManager stateManager;
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    // 1. Set Initial Data (Title only) so screen isn't blank
    if (widget.initialReportsViewerPage != null) {
      reportsViewerPage = widget.initialReportsViewerPage;
      // Don't set isLoading to false yet, because we likely don't have rows
    }

    // 2. ALWAYS fetch fresh data to get the Rows
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final idToFetch = widget.reportId ??
          widget.initialReportsViewerPage?.reportssView.reportInfo.id;

      if (idToFetch != null) {
        _fetchReportsViewerData(idToFetch);
      }
    });
  }

  void _fetchReportsViewerData(String reportId) async {
    // Only show loader if we don't have data yet
    if (rows.isEmpty) {
      setState(() => isLoading = true);
    }

    final FetchReportsPage fetchReportsPage =
        serviceLocator<FetchReportsPage>();

    final result = await fetchReportsPage.call(
      FetchReportsPageParams(requestId: reportId),
    );

    result.fold(
      (failure) {
        if (!mounted) return;
        setState(() => isLoading = false);
        SmartNotifier.error(
          context,
          title: AppLocalizations.of(context)!.error,
          message: failure.message,
        );
      },
      (data) {
        if (!mounted) return;
        setState(() {
          reportsViewerPage = data;
          _preparePlutoGrid();
          gridKey = UniqueKey(); // Force Grid Rebuild
          isLoading = false;
        });
      },
    );
  }

  MaterialColor _getStatusColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('pending') || lower.contains('wait')) {
      return Colors.orange;
    }
    if (lower.contains('approv') ||
        lower.contains('success') ||
        lower.contains('done')) {
      return Colors.green;
    }
    if (lower.contains('reject') ||
        lower.contains('error') ||
        lower.contains('cancel')) {
      return Colors.red;
    }
    return Colors.blue;
  }

  void _preparePlutoGrid() {
    if (reportsViewerPage == null) return;
    if (!mounted) return;

    final locale = Localizations.localeOf(context).languageCode;
    final viewData = reportsViewerPage!.reportssView;
    final isAr = locale == 'ar';

    columns = viewData.columns.map((colMeta) {
      return PlutoColumn(
        title: isAr ? colMeta.labelAr : colMeta.labelEn,
        field: colMeta.columnKey,
        type: _getPlutoType(colMeta.columnType),
        enableEditingMode: false,
        enableFilterMenuItem: true,
        enableSorting: true,
        textAlign:
            isAr ? PlutoColumnTextAlign.right : PlutoColumnTextAlign.left,
        titleTextAlign:
            isAr ? PlutoColumnTextAlign.right : PlutoColumnTextAlign.left,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          final type = colMeta.columnType.toLowerCase();
          final key = colMeta.columnKey.toLowerCase();

          if (type == 'lookup' ||
              key.contains('status') ||
              key.contains('type')) {
            final color = _getStatusColor(value);
            return Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.shade700,
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              value,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          );
        },
      );
    }).toList();

    rows = viewData.rows.map((rowMap) {
      final cells = <String, PlutoCell>{};
      for (var col in viewData.columns) {
        final rawValue = rowMap[col.columnKey];
        var formattedValue = rawValue?.toString() ?? '';
        if (col.columnType == 'date' && rawValue != null) {
          final date = DateTime.tryParse(rawValue.toString());
          if (date != null) {
            formattedValue = intl.DateFormat('yyyy-MM-dd').format(date);
          }
        }
        cells[col.columnKey] = PlutoCell(value: formattedValue);
      }
      return PlutoRow(cells: cells);
    }).toList();
  }

  PlutoColumnType _getPlutoType(String type) {
    switch (type.toLowerCase()) {
      case 'number':
      case 'int':
      case 'double':
        return PlutoColumnType.number();
      case 'date':
      case 'datetime':
        return PlutoColumnType.date(format: 'yyyy-MM-dd');
      case 'text':
      default:
        return PlutoColumnType.text();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isAr = locale == 'ar';
    final title = reportsViewerPage?.reportssView.getTitle(locale) ??
        AppLocalizations.of(context)!.report;

    // Height Calculation
    final double maxAvailableHeight = MediaQuery.of(context).size.height - 180;
    const double rowHeight = 52.0;
    const double headerHeight = 52.0;
    final double contentHeight = (rows.length * rowHeight) + headerHeight + 50;
    final double gridHeight = math.min(contentHeight, maxAvailableHeight);

    return CustomScaffold(
      title: title,
      tilteActions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            if (reportsViewerPage?.reportssView.reportInfo.id != null) {
              _fetchReportsViewerData(
                  reportsViewerPage!.reportssView.reportInfo.id);
            }
          },
        ),
      ],
      body: [
        if (isLoading)
          const Loader()
        else if (reportsViewerPage == null || rows.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(AppLocalizations.of(context)!.noResults),
            ),
          )
        else
          Container(
            height: gridHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: PlutoGrid(
                  key: gridKey,
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                  configuration: PlutoGridConfiguration(
                    columnSize: const PlutoGridColumnSizeConfig(
                      autoSizeMode: PlutoAutoSizeMode.scale,
                    ),
                    localeText: isAr
                        ? const PlutoGridLocaleText.arabic()
                        : const PlutoGridLocaleText(),
                    style: PlutoGridStyleConfig(
                      gridBackgroundColor: Colors.white,
                      rowHeight: rowHeight,
                      columnHeight: headerHeight,
                      enableGridBorderShadow: false,
                      borderColor: Colors.transparent,
                      gridBorderColor: Colors.transparent,
                      enableColumnBorderVertical: false,
                      columnTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      cellTextStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      oddRowColor: const Color(0xFFF9FAFB),
                      evenRowColor: Colors.white,
                      activatedColor: const Color(0xFFF3F4F6),
                      activatedBorderColor: Colors.blue.withOpacity(0.3),
                      iconColor: Colors.grey.shade400,
                      menuBackgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
