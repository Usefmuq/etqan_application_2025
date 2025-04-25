part of 'home_screen_bloc.dart';

@immutable
sealed class HomeScreenState {}

final class HomeScreenInitial extends HomeScreenState {}

final class HomeScreenLoading extends HomeScreenState {}

final class HomeScreenFailure extends HomeScreenState {
  final String error;
  HomeScreenFailure(this.error);
}

final class HomeScreenShowAllSuccess extends HomeScreenState {
  final HomeScreenPageEntity homeScreenPage;
  HomeScreenShowAllSuccess(this.homeScreenPage);
}
