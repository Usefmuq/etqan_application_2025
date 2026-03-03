import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_directory.dart';
import 'package:etqan_application_2025/src/features/reports/domain/entities/report_columns_meta.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_directory_model.dart';

class ReportssPageViewModel {
  final ReportsDirectory reportInfo;
  final List<ReportColumnsMeta> columns;
  final List<Map<String, dynamic>> rows;

  const ReportssPageViewModel({
    required this.reportInfo,
    required this.columns,
    required this.rows,
  });

  // 👇 ADD THIS FACTORY
  factory ReportssPageViewModel.fromDirectory(Map<String, dynamic> json) {
    return ReportssPageViewModel(
      // We parse the Directory info
      reportInfo: ReportsDirectoryModel.fromJson(json),
      // We leave the heavy data empty for the list view
      columns: const [],
      rows: const [],
    );
  }

  // Helper to get title
  String getTitle(String locale) =>
      locale == 'ar' ? reportInfo.titleAr : reportInfo.titleEn;

  // Helper to get description
  String getDescription(String locale) => locale == 'ar'
      ? (reportInfo.descriptionAr ?? '')
      : (reportInfo.descriptionEn ?? '');
}
