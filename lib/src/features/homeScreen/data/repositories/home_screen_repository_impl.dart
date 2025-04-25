import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/homeScreen/data/datasources/home_screen_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/repositories/home_screen_repository.dart';
import 'package:fpdart/fpdart.dart';

class HomeScreenRepositoryImpl implements HomeScreenRepository {
  final HomeScreenRemoteDataSource homeScreenRemoteDataSource;
  const HomeScreenRepositoryImpl(
    this.homeScreenRemoteDataSource,
  );

  @override
  Future<Either<Failure, HomeScreenPageEntity>> getAllHomeScreens() async {
    try {
      final homeScreensVeiw =
          await homeScreenRemoteDataSource.getAllHomeScreensView();
      return right(homeScreensVeiw);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
