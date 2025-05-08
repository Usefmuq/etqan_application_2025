import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/repositories/home_screen_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllServices
    implements Usecase<HomeScreenPageEntity, GetAllServicesParams> {
  final HomeScreenRepository homeScreenRepostory;
  GetAllServices(this.homeScreenRepostory);
  @override
  Future<Either<Failure, HomeScreenPageEntity>> call(
      GetAllServicesParams params) async {
    return await homeScreenRepostory.getAllHomeScreens(params.user);
  }
}

class GetAllServicesParams {
  final User user;

  GetAllServicesParams({
    required this.user,
  });
}
