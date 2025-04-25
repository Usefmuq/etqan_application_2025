import 'package:etqan_application_2025/src/core/data/models/service_master_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class HomeScreenRemoteDataSource {
  Future<HomeScreenPageEntity> getAllHomeScreensView();
}

class HomeScreenRemoteDataSourceImpl implements HomeScreenRemoteDataSource {
  final SupabaseClient supabaseClient;
  HomeScreenRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<HomeScreenPageEntity> getAllHomeScreensView() async {
    try {
      final servicesResult = await supabaseClient
          .from('services_master')
          .select('*')
          .eq('is_active', true);
      return HomeScreenPageEntity(
          services: servicesResult
              .map((services) => ServiceMasterModel.fromJson(services))
              .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
