import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/repositories/vacation_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllVacations
    implements Usecase<VacationPageEntity, GetAllVacationsParams> {
  final VacationRepository vacationRepostory;
  GetAllVacations(this.vacationRepostory);
  @override
  Future<Either<Failure, VacationPageEntity>> call(
      GetAllVacationsParams params) async {
    return await vacationRepostory.getAllVacations(
      user: params.user,
      departmentId: params.departmentId,
      isManagerExpanded: params.isManagerExpanded,
      isDepartmentManagerExpanded: params.isDepartmentManagerExpanded,
      isViewAll: params.isViewAll,
    );
  }
}

class GetAllVacationsParams {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;

  GetAllVacationsParams({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
