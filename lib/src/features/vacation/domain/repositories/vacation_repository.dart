import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class VacationRepository {
  Future<Either<Failure, VacationViewerPageEntity>> submitVacation({
    required String createdById,
    required String vacationTypeId,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
    required double daysCount,
  });
  Future<Either<Failure, VacationViewerPageEntity>> updateVacation({
    required VacationsPageViewModel vacationViewerPage,
    required String updatedBy,
  });
  Future<Either<Failure, VacationViewerPageEntity>> approveVacation({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required VacationsPageViewModel vacationModel,
  });
  Future<Either<Failure, VacationPageEntity>> getAllVacations({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  });
  Future<Either<Failure, VacationViewerPageEntity>> fetchVacationViewerPage({
    required int requestId,
  });
}
