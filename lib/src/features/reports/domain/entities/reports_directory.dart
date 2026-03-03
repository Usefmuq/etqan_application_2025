class ReportsDirectory {
  final String id;
  final String reportKey;
  final String titleEn;
  final String titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String viewName;
  final bool isActive;
  final DateTime createdAt;

  const ReportsDirectory({
    required this.id,
    required this.reportKey,
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.viewName,
    required this.isActive,
    required this.createdAt,
  });
}
