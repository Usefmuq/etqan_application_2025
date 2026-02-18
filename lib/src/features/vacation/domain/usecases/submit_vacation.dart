import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/repositories/vacation_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitVacation
    implements Usecase<VacationViewerPageEntity, SubmitVacationParams> {
  final VacationRepository vacationRepostory;
  SubmitVacation(this.vacationRepostory);
  @override
  Future<Either<Failure, VacationViewerPageEntity>> call(
      SubmitVacationParams params) async {
    return await vacationRepostory.submitVacation(
      createdById: params.createdById,
      vacationTypeId: params.vacationTypeId,
      reason: params.reason,
      startDate: params.startDate,
      endDate: params.endDate,
      daysCount: params.daysCount,
    );
  }
}

class SubmitVacationParams {
  final String createdById;
  final String vacationTypeId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final double daysCount;

  SubmitVacationParams({
    required this.createdById,
    required this.vacationTypeId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
  });
}
