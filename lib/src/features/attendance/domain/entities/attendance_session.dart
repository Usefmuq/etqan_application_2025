// attendance_session.dart
class AttendanceSession {
  final String id;
  final String userId;
  final String sourceKey;
  final String? siteId;
  final bool? insideSite;
  final DateTime startAt;
  final DateTime? endAt;
  final String? note;

  // NEW: coords
  final double? startLat;
  final double? startLng;
  final double? startAccuracyM;
  final double? endLat;
  final double? endLng;
  final double? endAccuracyM;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final DateTime? workDateLocal; // returned by DB if you select it

  AttendanceSession({
    required this.id,
    required this.userId,
    required this.sourceKey,
    this.siteId,
    this.insideSite,
    required this.startAt,
    this.endAt,
    this.note,
    this.startLat,
    this.startLng,
    this.startAccuracyM,
    this.endLat,
    this.endLng,
    this.endAccuracyM,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.workDateLocal,
  });
}
