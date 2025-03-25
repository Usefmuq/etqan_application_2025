import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';

class UuidLookupConstants {
  static const Map<String, Map<String, dynamic>> requestStatusMap = {
    '05095d22-e667-4f47-80c9-ff27d81f74fb': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'color': AppPallete.inProgressColor,
    },
    '095a7934-bafc-4f92-98fc-89e471b7d698': {
      'en': 'Completed',
      'ar': 'مكتمل',
      'color': AppPallete.completedColor,
    },
    '1593bad1-d843-4323-a673-36cc01df315a': {
      'en': 'In Progress',
      'ar': 'قيد التنفيذ',
      'color': AppPallete.rejectColor,
    },
  };

  static const Map<String, Map<String, String>> priorityMap = {
    'uuid-high': {
      'en': 'High',
      'ar': 'عالية',
    },
    'uuid-medium': {
      'en': 'Medium',
      'ar': 'متوسطة',
    },
    'uuid-low': {
      'en': 'Low',
      'ar': 'منخفضة',
    },
  };

  static final Map<String, Map<String, dynamic>> combinedLookup = {
    ...requestStatusMap,
    ...priorityMap,
  };
}
