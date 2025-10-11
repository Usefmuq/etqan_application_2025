import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllAttendances
    implements Usecase<AttendancePageEntity, GetAllAttendancesParams> {
  final AttendanceRepository attendanceRepostory;
  GetAllAttendances(this.attendanceRepostory);
  @override
  Future<Either<Failure, AttendancePageEntity>> call(
      GetAllAttendancesParams params) async {
    return await attendanceRepostory.getAllAttendances(
      user: params.user,
      departmentId: params.departmentId,
      isManagerExpanded: params.isManagerExpanded,
      isDepartmentManagerExpanded: params.isDepartmentManagerExpanded,
      isViewAll: params.isViewAll,
    );
  }
}

class GetAllAttendancesParams {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;

  GetAllAttendancesParams({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
