import 'dart:math' as math;
import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/fetch_attendance_reports.dart';

// IMPORTANT: Import your new dedicated Attendance UseCase here
// import 'package:etqan_application_2025/src/features/reports/domain/usecases/fetch_attendance_report.dart';

// IMPORTANT: Import your UserModel and User fetching functions here
// import 'package:etqan_application_2025/src/core/data/models/user_model.dart';
// import 'package:etqan_application_2025/src/core/utils/user_utils.dart'; // Where fetchAllUsers is

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pluto_grid/pluto_grid.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  static route() => MaterialPageRoute(
        builder: (context) => const AttendanceReportPage(),
      );

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  ReportsViewerPageEntity? rawReportData;
  bool isLoading = true;
  Key gridKey = UniqueKey();

  late final PlutoGridStateManager stateManager;
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  // User & Permission State
  List<String>? permissions;
  List<dynamic> employeesList = []; // Replace 'dynamic' with 'UserModel'
  String? selectedEmployeeId;

  // Date Scope (Defaults to Last 30 Days)
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
      return;
    }

    final currentUser = userState.user;
    final userId = currentUser.id;

    Future.microtask(() async {
      try {
        // 1. Fetch Permissions
        final fetchedPermissions = await fetchUserPermissions(userId);

        // 2. Determine Scope
        final canViewAll = isUserHasPermissionsView(
          fetchedPermissions ?? [],
          PermissionsConstants
              .viewAllAttendance, // Ensure this exists in your constants
        );

        final canViewDept = isUserHasPermissionsView(
          fetchedPermissions ?? [],
          PermissionsConstants
              .viewDepartmentAttendance, // Ensure this exists in your constants
        );

        // 3. Fetch Employees based on scope
        List<dynamic> fetchedEmployees =
            []; // Replace 'dynamic' with 'UserModel'
        if (canViewAll) {
          fetchedEmployees = await fetchAllUsers();
        } else if (canViewDept) {
          fetchedEmployees =
              await fetchUsersByDepartment(currentUser.departmentId);
        } else {
          fetchedEmployees = [currentUser]; // Normal user only sees themselves
        }

        if (!mounted) return;
        setState(() {
          permissions = fetchedPermissions;
          employeesList = fetchedEmployees;

          // Auto-select logged-in user or first available
          if (employeesList.isNotEmpty) {
            final me = employeesList.where((e) => e.id == userId).firstOrNull;
            selectedEmployeeId = me?.id ?? employeesList.first.id;
          }
        });

        // 4. Setup Columns and Fetch Data
        _setupColumns();
        if (selectedEmployeeId != null) {
          await _fetchAttendanceData();
        } else {
          setState(() => isLoading = false);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => isLoading = false);
        SmartNotifier.error(
          context,
          title: AppLocalizations.of(context)!.error,
          message: e.toString(),
        );
      }
    });
  }

  Future<void> _fetchAttendanceData() async {
    setState(() => isLoading = true);

    // Call your brand new UseCase!
    final FetchAttendanceReport fetchAttendanceReport =
        serviceLocator<FetchAttendanceReport>();

    final result = await fetchAttendanceReport.call(
      FetchAttendanceParams(
        selectedEmployeeId: selectedEmployeeId!,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold(
      (failure) {
        if (!mounted) return;
        setState(() => isLoading = false);
        SmartNotifier.error(context, title: "Error", message: failure.message);
      },
      (data) {
        if (!mounted) return;
        setState(() {
          // data is now your ReportsViewerPageEntity!
          rawReportData = data;

          // Pass the rows to the grid
          _populateRows(data.reportssView.rows);

          gridKey = UniqueKey();
          isLoading = false;
        });
      },
    );
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      await _fetchAttendanceData();
    }
  }

  MaterialColor _getStatusColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('vacation')) return Colors.purple;
    if (lower.contains('absent')) return Colors.red;
    if (lower.contains('weekend')) return Colors.grey;
    if (lower.contains('late')) return Colors.orange;
    if (lower.contains('present') || lower.contains('on time')) {
      return Colors.green;
    }
    return Colors.blue;
  }

  void _setupColumns() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final align = isAr ? PlutoColumnTextAlign.right : PlutoColumnTextAlign.left;

    columns = [
      PlutoColumn(
        title: isAr ? 'التاريخ' : 'Date',
        field: 'date',
        type: PlutoColumnType.date(format: 'yyyy-MM-dd'),
        textAlign: align,
        titleTextAlign: align,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: isAr ? 'اليوم' : 'Day',
        field: 'day_name',
        type: PlutoColumnType.text(),
        textAlign: align,
        titleTextAlign: align,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: isAr ? 'دخول' : 'In',
        field: 'first_check_in',
        type: PlutoColumnType.text(),
        textAlign: align,
        titleTextAlign: align,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: isAr ? 'خروج' : 'Out',
        field: 'last_check_out',
        type: PlutoColumnType.text(),
        textAlign: align,
        titleTextAlign: align,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: isAr ? 'الساعات' : 'Hours',
        field: 'total_hours',
        type: PlutoColumnType.text(),
        textAlign: align,
        titleTextAlign: align,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: isAr ? 'الحالة' : 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        textAlign: align,
        titleTextAlign: align,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          final color = _getStatusColor(value);

          if (value.toLowerCase().contains('weekend')) {
            return Center(
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic)));
          }

          return Align(
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    color: color.shade700),
              ),
            ),
          );
        },
      ),
    ];
  }

  void _populateRows(List<dynamic> dbData) {
    rows = dbData.map((rowMap) {
      String formatTime(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return '-';
        final d = DateTime.tryParse(dateStr);
        return d != null ? intl.DateFormat('HH:mm').format(d) : '-';
      }

      return PlutoRow(cells: {
        'date': PlutoCell(value: rowMap['date']?.toString() ?? '-'),
        'day_name': PlutoCell(value: rowMap['day_name']?.toString() ?? '-'),
        'first_check_in':
            PlutoCell(value: formatTime(rowMap['first_check_in']?.toString())),
        'last_check_out':
            PlutoCell(value: formatTime(rowMap['last_check_out']?.toString())),
        'total_hours':
            PlutoCell(value: rowMap['total_hours']?.toString() ?? '-'),
        'status': PlutoCell(value: rowMap['status']?.toString() ?? 'Absent'),
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isAr = locale == 'ar';
    final title = isAr ? 'تقرير الحضور' : 'Attendance Report';

    final double maxAvailableHeight = MediaQuery.of(context).size.height - 240;
    final double contentHeight = (rows.length * 52.0) + 52.0 + 50;
    final double gridHeight = math.min(contentHeight, maxAvailableHeight);

    return CustomScaffold(
      title: title,
      tilteActions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            if (selectedEmployeeId != null) _fetchAttendanceData();
          },
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Employee Picker (Only shows if user manages > 1 employee)
              if (employeesList.length > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedEmployeeId,
                      icon:
                          const Icon(Icons.person_outline, color: Colors.blue),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedEmployeeId = val);
                          _fetchAttendanceData();
                        }
                      },
                      items: employeesList.map((user) {
                        // FIX: Adjust mapping based on your UserModel
                        final name = isAr ? user.firstNameAr : user.firstNameEn;
                        return DropdownMenuItem<String>(
                            value: user.id,
                            child: Text(name ?? 'Unknown Employee'));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 2. Date Range Picker
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "${intl.DateFormat('MMM dd, yyyy').format(startDate)}  -  ${intl.DateFormat('MMM dd, yyyy').format(endDate)}",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800),
                          ),
                        ],
                      ),
                      Icon(Icons.edit_calendar,
                          color: Colors.blue.shade700, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- GRID AREA ---
        if (isLoading)
          const Loader()
        else if (rows.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.noResults,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          Container(
            height: gridHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
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
                  onLoaded: (e) => stateManager = e.stateManager,
                  configuration: PlutoGridConfiguration(
                    columnSize: const PlutoGridColumnSizeConfig(
                      autoSizeMode: PlutoAutoSizeMode.scale,
                    ),
                    localeText: isAr
                        ? const PlutoGridLocaleText.arabic()
                        : const PlutoGridLocaleText(),
                    style: PlutoGridStyleConfig(
                      gridBackgroundColor: Colors.white,
                      rowHeight: 52,
                      columnHeight: 52,
                      enableGridBorderShadow: false,
                      borderColor: Colors.transparent,
                      gridBorderColor: Colors.transparent,
                      enableColumnBorderVertical: false,
                      columnTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87),
                      cellTextStyle:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  rowColorCallback: (ctx) {
                    final status = ctx.row.cells['status']?.value
                            .toString()
                            .toLowerCase() ??
                        '';
                    if (status.contains('weekend')) return Colors.grey.shade100;
                    if (status.contains('vacation')) {
                      return Colors.purple.shade50;
                    }
                    if (status.contains('absent')) {
                      return Colors.red.withOpacity(0.03);
                    }
                    return ctx.rowIdx % 2 == 0
                        ? Colors.white
                        : const Color(0xFFF9FAFB);
                  },
                ),
              ),
            ),
          ),
        const SizedBox(height: 40),
      ],
    );
  }
}
