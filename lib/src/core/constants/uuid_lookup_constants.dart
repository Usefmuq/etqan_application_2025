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
      'color': AppPallete.inProgressColor,
    },
    '682c5e5a-8280-4379-9bd5-3e35f18b4cf7': {
      'en': 'Returned For Correction',
      'ar': 'إرجاع الطلب للتصحيح',
      'color': AppPallete.gradient1,
    },
    'd887c1c9-2f59-478c-90f7-f8921d57d032': {
      'en': 'Rejected',
      'ar': 'مرفوض',
      'color': AppPallete.rejectColor,
    },
  };
  static const Map<String, Map<String, dynamic>> userStatusMap = {
    '388e4fe0-1b39-4e9b-b6d0-c58d5f317b33': {
      'en': 'Inactive',
      'ar': 'غير نشط',
      'color': AppPallete.inProgressColor,
    },
    '3beb63e3-42f2-4b85-aed9-64ca95a1426f': {
      'en': 'Active',
      'ar': 'نشط',
      'color': AppPallete.completedColor,
    },
    '5705a545-7542-494f-afac-714c7ad858ef': {
      'en': 'Suspended',
      'ar': 'معلق',
      'color': AppPallete.errorColor,
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
    '96605a1f-f800-43d0-9519-7bfe2e1b8468': {
      'en': 'Returned For Correction',
      'ar': 'إرجاع الطلب للتصحيح',
      'color': AppPallete.gradient1,
    },
  };

  static final Map<String, Map<String, dynamic>> combinedLookup = {
    ...requestStatusMap,
    ...approvalStatusMap,
    ...userStatusMap,
  };
}
