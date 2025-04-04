import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitOnboarding implements Usecase<Onboarding, SubmitOnboardingParams> {
  final OnboardingRepository onboardingRepostory;
  SubmitOnboarding(this.onboardingRepostory);
  @override
  Future<Either<Failure, Onboarding>> call(
      SubmitOnboardingParams params) async {
    return await onboardingRepostory.submitOnboarding(
      firstNameEn: params.firstNameEn,
      lastNameEn: params.lastNameEn,
      firstNameAr: params.firstNameAr,
      lastNameAr: params.lastNameAr,
      email: params.email,
      phone: params.phone,
      departmentId: params.departmentId,
      positionId: params.positionId,
      reportTo: params.reportTo,
      startDate: params.startDate,
      createdBy: params.createdBy,
      notes: params.notes,
    );
  }
}

class SubmitOnboardingParams {
  final String createdBy;
  final String firstNameEn;
  final String lastNameEn;
  final String firstNameAr;
  final String lastNameAr;
  final String email;
  final String phone;
  final String departmentId;
  final String positionId;
  final String reportTo;
  final DateTime startDate;
  final String notes;

  SubmitOnboardingParams({
    required this.createdBy,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.firstNameAr,
    required this.lastNameAr,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.positionId,
    required this.reportTo,
    required this.startDate,
    required this.notes,
  });
}
