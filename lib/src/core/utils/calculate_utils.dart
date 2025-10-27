// int calculateTime() {
//   return 1;
// }

import 'dart:math' as math;

double? distanceMetersNullable({
  double? lat1,
  double? lng1,
  double? lat2,
  double? lng2,
}) {
  // Null / non-finite guard
  if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) return null;
  if (!lat1.isFinite || !lng1.isFinite || !lat2.isFinite || !lng2.isFinite) {
    return null;
  }

  const double R = 6371000; // meters
  final double dLat = _deg2rad(lat2 - lat1);
  final double dLon = _deg2rad(lng2 - lng1);

  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) *
          math.cos(_deg2rad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return R * c;
}

double _deg2rad(double deg) => deg * (math.pi / 180.0);

/// Convenience: kilometers (nullable passthrough)
double? distanceKmNullable({
  double? lat1,
  double? lng1,
  double? lat2,
  double? lng2,
}) {
  final m =
      distanceMetersNullable(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2);
  return m == null ? null : m / 1000.0;
}
