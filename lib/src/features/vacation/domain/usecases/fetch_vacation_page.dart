import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/repositories/vacation_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchVacationPage
    implements Usecase<VacationViewerPageEntity, FetchVacationPageParams> {
  final VacationRepository vacationRepostory;
  FetchVacationPage(this.vacationRepostory);
  @override
  Future<Either<Failure, VacationViewerPageEntity>> call(
      FetchVacationPageParams params) async {
    return await vacationRepostory.fetchVacationViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchVacationPageParams {
  final int requestId;

  FetchVacationPageParams({
    required this.requestId,
  });
}
