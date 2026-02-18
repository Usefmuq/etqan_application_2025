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
  static const Map<String, Map<String, dynamic>> vacationTypeMap = {
    '5a5dd595-79f1-419a-8285-ceeb3871cf52': {
      'en': 'Annual Leave',
      'ar': 'إجازة سنوية',
      'color': AppPallete.inProgressColor,
    },
    '6a7b3e2b-b992-438e-9323-0a97a9b267de': {
      'en': 'Sick Leave',
      'ar': 'إجازة مرضية',
      'color': AppPallete.greyColor,
    },
    'db2fdb25-f6ea-407d-bed4-bb2f39d7eed6': {
      'en': 'Unpaid Leave',
      'ar': 'إجازة بدون راتب',
      'color': AppPallete.completedColor,
    },
    'f85f51f1-37f9-45b2-860c-b8cb2c51f2c5': {
      'en': 'Emergency Leave',
      'ar': 'إجازة اضطرارية',
      'color': AppPallete.rejectColor,
    },
    'c802154f-b589-4f12-b7c4-8e64e8e605a3': {
      'en': 'Maternity Leave',
      'ar': 'إجازة وضع (أمومة)',
      'color': AppPallete.gradient1,
    },
    '9bbd2b4c-16fb-49ae-914d-7a9df08ad585': {
      'en': 'Paternity Leave',
      'ar': 'إجازة مولود (أبوة)',
      'color': AppPallete.gradient1,
    },
    '14013bdd-3b39-42c1-bd5e-4986c4f3638b': {
      'en': 'Marriage Leave',
      'ar': 'إجازة زواج',
      'color': AppPallete.gradient1,
    },
    'd94d9702-2f02-4e4d-897e-5a86c5e8b742': {
      'en': 'Bereavement Leave',
      'ar': 'إجازة وفاة',
      'color': AppPallete.gradient1,
    },
    '0e7b1cbb-bfd6-4d7f-917c-8f9a18e83769': {
      'en': 'Hajj Leave',
      'ar': 'إجازة حج',
      'color': AppPallete.gradient1,
    },
    '47b88135-2f7c-44a5-b996-1132d90f1c66': {
      'en': 'Examination Leave',
      'ar': 'إجازة اختبارات',
      'color': AppPallete.gradient1,
    },
  };

  static final Map<String, Map<String, dynamic>> combinedLookup = {
    ...requestStatusMap,
    ...approvalStatusMap,
    ...userStatusMap,
    ...vacationTypeMap,
  };
}
