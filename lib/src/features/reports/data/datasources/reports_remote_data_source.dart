import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/report_columns_meta_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_directory_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_directory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ReportsRemoteDataSource {
  Future<List<ReportssPageViewModel>> getAllReportssView();
  Future<ReportssPageViewModel> getReportsViewByRequestId(String requestId);
  Future<ReportssPageViewModel> getAttendanceReports(
    String selectedEmployeeId,
    DateTime startDate,
    DateTime endDate,
  );
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final SupabaseClient supabaseClient;
  ReportsRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ReportssPageViewModel>> getAllReportssView() async {
    try {
      final data = await supabaseClient
          .from('reports_directory')
          .select() // 👈 CHANGED: Fetch all columns (id, view_name, etc.)
          .eq('is_active', true)
          .order('created_at');

      return (data as List)
          .map((e) => ReportssPageViewModel.fromDirectory(e))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReportssPageViewModel> getReportsViewByRequestId(
      String reportId) async {
    try {
      // 1. Fetch the Report Info (Directory)
      // We map it to the Model you created
      final reportDirData = await supabaseClient
          .from('reports_directory')
          .select()
          .eq('id', reportId)
          .single();

      final reportInfo = ReportsDirectoryModel.fromJson(reportDirData);

      // 2. Fetch the Columns Configuration
      final columnsData = await supabaseClient
          .from('report_columns_meta')
          .select()
          .eq('report_id', reportId)
          .eq('is_visible', true) // Only fetch visible columns
          .order('order_index');

      final columns = (columnsData as List)
          .map((e) => ReportColumnsMetaModel.fromJson(e))
          .toList();

      // 3. Fetch the REAL Data (Using the 'view_name' from step 1)
      // This is the dynamic part!
      final rowsData = await supabaseClient.from(reportInfo.viewName).select();

      final rows = List<Map<String, dynamic>>.from(rowsData);

      // 4. Return the Bundled Container
      return ReportssPageViewModel(
        reportInfo: reportInfo,
        columns: columns,
        rows: rows,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReportssPageViewModel> getAttendanceReports(
    String selectedEmployeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 1. Make the Supabase Call
      final response = await supabaseClient
          .from('attendance_rolling_year_view')
          .select()
          .eq('user_id', selectedEmployeeId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      // 2. Parse the rows
      final rows = List<Map<String, dynamic>>.from(response);

      // 3. Return it packaged as your standard ViewModel/Entity!
      return ReportssPageViewModel(
        // We can pass empty/dummy values for info and columns
        // because our new UI completely handles the titles and columns locally!
        reportInfo: ReportsDirectory(
          id: 'attendance',
          reportKey: 'ATTENDANCE_ROLLING',
          titleEn: 'Attendance',
          titleAr: 'الحضور',
          viewName: '',
          isActive: true,
          createdAt: DateTime.now(),
        ),
        columns: [], // Ignored by the new UI
        rows: rows, // The actual data the UI needs!
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
