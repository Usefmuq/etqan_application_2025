import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HomeScreenRepository {
  Future<Either<Failure, HomeScreenPageEntity>> getAllHomeScreens(User user);
}
