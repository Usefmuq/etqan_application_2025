import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/repositories/home_screen_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllServices implements Usecase<HomeScreenPageEntity, NoParams> {
  final HomeScreenRepository homeScreenRepostory;
  GetAllServices(this.homeScreenRepostory);
  @override
  Future<Either<Failure, HomeScreenPageEntity>> call(NoParams params) async {
    return await homeScreenRepostory.getAllHomeScreens();
  }
}
