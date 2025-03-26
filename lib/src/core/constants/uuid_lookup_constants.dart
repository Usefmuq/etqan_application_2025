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
  static const Map<String, Map<String, dynamic>> approvalStatusMap = {
    '1968dba5-db7a-4d7c-bc5a-956dd2ff9d20': {
      'en': 'Pending',
      'ar': 'قيد الانتظار',
      'color': AppPallete.inProgressColor,
    },
    'f343a374-eb8b-444f-bced-fb90fbfcf55a': {
      'en': 'Queued',
      'ar': 'لم يبدأ بعد',
      'color': AppPallete.greyColor,
    },
    '3df55920-3446-4b68-9542-c4eb1a969aef': {
      'en': 'Approved',
      'ar': 'موافق عليه',
      'color': AppPallete.completedColor,
    },
    'f05437f4-0305-4aa5-909d-9e54d2f4a409': {
      'en': 'Rejected',
      'ar': 'مرفوض',
      'color': AppPallete.rejectColor,
    },
  };

  static final Map<String, Map<String, dynamic>> combinedLookup = {
    ...requestStatusMap,
    ...approvalStatusMap,
  };
}
