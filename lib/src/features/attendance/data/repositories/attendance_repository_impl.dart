import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource attendanceRemoteDataSource;
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const AttendanceRepositoryImpl(
    this.attendanceRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> submitAttendance({
    required AttendanceSessionModel attendance,
  }) async {
    try {
      RequestMasterModel requestMasterModel = RequestMasterModel(
        // requestId: 0,
        userId: 'createdById',
        serviceId: ServicesConstants.attendanceServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now().toUtc().add(Duration(hours: 3)),
        updatedAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      );
      final insertedAttendance = await attendanceRemoteDataSource
          .submitAttendance(attendance, requestMasterModel);
      return right(insertedAttendance);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> updateAttendance({
    required AttendancesPageViewModel attendanceViewerPage,
    required String updatedBy,
  }) async {
    try {
      final updatedAttendance =
          await attendanceRemoteDataSource.updateAttendance(
        attendanceViewerPage,
        updatedBy,
      );
      return right(updatedAttendance);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> approveAttendance({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required AttendancesPageViewModel attendanceModel,
  }) async {
    try {
      final approvedAttendance =
          await attendanceRemoteDataSource.approveAttendance(
        approvalSequenceModel,
        requestUnlockedFields,
        attendanceModel,
      );
      return right(approvedAttendance);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendancePageEntity>> getAllAttendances({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  }) async {
    try {
      final attendancesVeiw =
          await attendanceRemoteDataSource.getAllAttendancesView(
        user.id,
        departmentId,
        isManagerExpanded,
        isDepartmentManagerExpanded,
        isViewAll,
      );
      final approvalsView =
          await attendanceRemoteDataSource.getAllApprovalsView();
      return right(AttendancePageEntity(
        attendancesView: attendancesVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceViewerPageEntity>> fetchAttendanceViewerPage(
      {required int requestId}) async {
    try {
      final attendancesVeiw = await attendanceRemoteDataSource
          .getAttendanceViewByRequestId(requestId);
      final approvalsView = await attendanceRemoteDataSource
          .getApprovalViewByRequestId(requestId);
      return right(AttendanceViewerPageEntity(
        attendancesView: attendancesVeiw,
        approval: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
