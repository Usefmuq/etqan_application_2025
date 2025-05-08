import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/usecases/get_all_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final GetAllServices _getAllServices;
  HomeScreenBloc({
    required GetAllServices getAllServices,
  })  : _getAllServices = getAllServices,
        super(HomeScreenInitial()) {
    on<HomeScreenEvent>((event, emit) => emit(HomeScreenLoading()));
    on<HomeScreenGetAllHomeScreensEvent>(_onHomeScreenGetAllHomeScreensEvent);
  }

  void _onHomeScreenGetAllHomeScreensEvent(
    HomeScreenGetAllHomeScreensEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    final response =
        await _getAllServices(GetAllServicesParams(user: event.user));
    response.fold(
      (failure) => emit(HomeScreenFailure(failure.message)),
      (homeScreens) {
        emit(HomeScreenShowAllSuccess(homeScreens));
      },
    );
  }
}
