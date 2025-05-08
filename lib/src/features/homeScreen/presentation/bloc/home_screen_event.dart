part of 'home_screen_bloc.dart';

@immutable
sealed class HomeScreenEvent {}

final class HomeScreenGetAllHomeScreensEvent extends HomeScreenEvent {
  final User user;

  HomeScreenGetAllHomeScreensEvent({required this.user});
}
