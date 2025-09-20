import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogViewerPageEntity> submitBlog(
      BlogModel blog, RequestMasterModel request);
  Future<BlogViewerPageEntity> updateBlog(
    BlogsPageViewModel blog,
    String updatedBy,
  );
  Future<BlogViewerPageEntity> approveBlog(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    BlogsPageViewModel blog,
  );
  Future<List<BlogsPageViewModel>> getAllBlogsView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  );
  Future<BlogsPageViewModel> getBlogViewByRequestId(int requestId);
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView();
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId);
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;
  BlogRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<BlogViewerPageEntity> submitBlog(
    BlogModel blog,
    RequestMasterModel request,
  ) async {
    try {
      // SUBMIT
      final submitRes =
          await supabaseClient.rpc('rpc_service_submit_generic', params: {
        'p_service_id': ServicesConstants.blogServiceId, // int
        'p_entity_table': 'blogs',
        'p_view_name': 'blogs_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request': request.toJson(),
        'p_entity':
            blog.toJson(), // no need to include request_id; RPC injects it
      });
      final blogsView = BlogsPageViewModel.fromJson(submitRes['view']);
      final approvals = (submitRes['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return BlogViewerPageEntity(
        blogsView: blogsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BlogViewerPageEntity> updateBlog(
    BlogsPageViewModel blogViewerPage,
    String updatedBy,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_update_generic', params: {
        'p_service_id': ServicesConstants.blogServiceId,
        'p_entity_table': 'blogs',
        'p_view_name': 'blogs_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': blogViewerPage.requestId,
        'p_updated_by': updatedBy,
        'p_entity': {
          'title': blogViewerPage.title,
          'content': blogViewerPage.content,
          'topics': blogViewerPage.topics ?? <String>[], // if present in table
        },
      });
      final blogsView = BlogsPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return BlogViewerPageEntity(
        blogsView: blogsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BlogViewerPageEntity> approveBlog(
    ApprovalSequenceViewModel approvalSequence,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    BlogsPageViewModel blog,
  ) async {
    try {
      final res =
          await supabaseClient.rpc('rpc_service_approve_generic', params: {
        'p_entity_table': 'blogs',
        'p_view_name': 'blogs_page_view',
        'p_approvals_view': 'approval_sequence_view',
        'p_request_id': approvalSequence.requestId,
        'p_approval_id': approvalSequence.approvalId,
        'p_status_id': approvalSequence.approvalStatus,
        'p_comment': approvalSequence.approverComment ?? '',
        'p_approved_by': approvalSequence.approvedBy,
        'p_unlocked_fields':
            (requestUnlockedFields ?? []).map((e) => e.toJson()).toList(),
      });
      final blogsView = BlogsPageViewModel.fromJson(res['view']);
      final approvals = (res['approval'] as List)
          .map((j) => ApprovalSequenceViewModel.fromJson(j))
          .toList();

      return BlogViewerPageEntity(
        blogsView: blogsView,
        approval: approvals,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogsPageViewModel>> getAllBlogsView(
    String userId,
    String? departmentId,
    bool isManagerExpanded,
    bool isDepartmentManagerExpanded,
    bool isViewAll,
  ) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
      };

      if (!isViewAll) {
        if (isDepartmentManagerExpanded) {
          if (departmentId.isNullOrEmpty) {
            return [];
          }
          filters['department_id'] = departmentId!;
        } else if (isManagerExpanded) {
          if (userId.isNullOrEmpty) {
            return [];
          }

          filters['report_to'] = userId;
        } else {
          if (userId.isNullOrEmpty) {
            return [];
          }

          filters['created_by_id'] = userId;
        }
      }

      final result = await supabaseClient
          .from('blogs_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false);

      return result.map((blog) => BlogsPageViewModel.fromJson(blog)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BlogsPageViewModel> getBlogViewByRequestId(int requestId) async {
    try {
      final Map<String, Object> filters = {
        'request_is_active': true,
        'request_id': requestId,
      };

      final Map<String, dynamic>? row = await supabaseClient
          .from('blogs_page_view')
          .select('*')
          .match(filters)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        throw ServerException('Result view not found');
      }

      return BlogsPageViewModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApprovalSequenceViewModel>> getAllApprovalsView() async {
    try {
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq('service_id', ServicesConstants.blogServiceId)
          .eq('is_active', true);
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApprovalSequenceViewModel>> getApprovalViewByRequestId(
      int requestId) async {
    try {
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq('request_id', requestId)
          .eq('is_active', true);
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
