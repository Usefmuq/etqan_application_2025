import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_master_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/entities/home_screen_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etqan_application_2025/src/core/common/entities/user.dart' as u;

abstract interface class HomeScreenRemoteDataSource {
  Future<HomeScreenPageEntity> getAllHomeScreensView(u.User user);
}

class HomeScreenRemoteDataSourceImpl implements HomeScreenRemoteDataSource {
  final SupabaseClient supabaseClient;
  HomeScreenRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<HomeScreenPageEntity> getAllHomeScreensView(u.User user) async {
    try {
      final servicesResult = await supabaseClient
          .from('services_master')
          .select('*')
          .eq('is_active', true);
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq('approval_status', LookupConstants.approvalStatusApprovalPending)
          .eq('is_active', true)
          .or('approver_user_id.eq.${user.id},users_under_role_ids.ilike.%${user.id}%');

      return HomeScreenPageEntity(
          services: servicesResult
              .map((services) => ServiceMasterModel.fromJson(services))
              .toList(),
          approvals: approvalsView
              .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
              .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
