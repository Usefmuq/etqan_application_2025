import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/repositories/vacation_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateVacation
    implements Usecase<VacationViewerPageEntity, UpdateVacationParams> {
  final VacationRepository vacationRepostory;
  UpdateVacation(this.vacationRepostory);
  @override
  Future<Either<Failure, VacationViewerPageEntity>> call(
      UpdateVacationParams params) async {
    return await vacationRepostory.updateVacation(
      vacationViewerPage: params.vacationViewerPage,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateVacationParams {
  final VacationsPageViewModel vacationViewerPage;
  final String updatedBy;

  UpdateVacationParams({
    required this.vacationViewerPage,
    required this.updatedBy,
  });
}
