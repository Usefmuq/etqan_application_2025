class User {
  final String id;
  final String email;
  final String firstNameEn;
  final String lastNameEn;
  final String firstNameAr;
  final String lastNameAr;
  final String phone;
  final String departmentId;
  final String positionId;
  final String statusId;
  final String reportTo;
  final String languagePreference;
  final String timezone;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.firstNameAr,
    required this.lastNameAr,
    required this.phone,
    required this.departmentId,
    required this.positionId,
    required this.statusId,
    required this.reportTo,
    required this.languagePreference,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });
}
