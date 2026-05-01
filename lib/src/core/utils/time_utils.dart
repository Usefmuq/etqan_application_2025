List<String> generateTimeValues({int startHour = 7, int totalHours = 12}) {
  List<String> values = [];
  for (int i = 0; i < totalHours; i++) {
    int currentHour = startHour + i;
    if (currentHour >= 24) break;

    for (int minute = 0; minute < 60; minute += 15) {
      String h = currentHour.toString().padLeft(2, '0');
      String m = minute.toString().padLeft(2, '0');
      values.add('$h:$m'); // This is what goes into `items` and gets saved
    }
  }
  return values;
}

/// Converts the 24-hour string ("14:30") into a localized 12-hour display string ("02:30 PM" or "02:30 م")
String formatTimeForDisplay(String time24, String locale) {
  final parts = time24.split(':');
  if (parts.length != 2) return time24;

  int hour = int.tryParse(parts[0]) ?? 0;
  String minute = parts[1];

  // Localized AM/PM
  String amPmEn = hour < 12 ? 'AM' : 'PM';
  String amPmAr = hour < 12 ? 'ص' : 'م';
  String amPm = locale == 'ar' ? amPmAr : amPmEn;

  // Convert to 12-hour format
  int displayHour = hour % 12 == 0 ? 12 : hour % 12;

  return '${displayHour.toString().padLeft(2, '0')}:$minute $amPm';
}

String fmt(DateTime? date) {
  if (date == null) return '—';

  String y = date.year.toString();
  String m = date.month.toString().padLeft(2, '0');
  String d = date.day.toString().padLeft(2, '0');

  return "$y-$m-$d";
}
