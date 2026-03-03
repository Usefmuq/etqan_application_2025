class ReportColumnsMeta {
  final String id;
  final String reportId;
  final String columnKey;
  final String labelEn;
  final String labelAr;
  final String columnType;
  final int orderIndex;
  final bool isVisible;

  const ReportColumnsMeta({
    required this.id,
    required this.reportId,
    required this.columnKey,
    required this.labelEn,
    required this.labelAr,
    required this.columnType,
    required this.orderIndex,
    required this.isVisible,
  });
}
