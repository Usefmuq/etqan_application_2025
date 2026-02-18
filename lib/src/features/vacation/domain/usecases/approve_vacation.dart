import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/repositories/vacation_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveVacation
    implements Usecase<VacationViewerPageEntity, ApproveVacationParams> {
  final VacationRepository vacationRepostory;
  ApproveVacation(this.vacationRepostory);
  @override
  Future<Either<Failure, VacationViewerPageEntity>> call(
      ApproveVacationParams params) async {
    return await vacationRepostory.approveVacation(
      requestUnlockedFields: params.requestUnlockedFields,
      approvalSequenceModel: params.approvalSequenceModel,
      vacationModel: params.vacationModel,
    );
  }
}

class ApproveVacationParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;

  final VacationsPageViewModel vacationModel;

  ApproveVacationParams({
    required this.approvalSequenceModel,
    this.requestUnlockedFields,
    required this.vacationModel,
  });
}
