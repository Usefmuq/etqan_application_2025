import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> submitBlog(BlogModel blog, RequestMasterModel request);
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
  Future<BlogModel> submitBlog(
    BlogModel blog,
    RequestMasterModel request,
  ) async {
    try {
      final serviceAprovalUsersData = await supabaseClient
          .from('service_approval_users')
          .select('*')
          .eq('service_id', ServicesConstants.blogServiceId)
          .eq('is_active', true);
      final serviceApprovalUsers = serviceAprovalUsersData
          .map((item) => ServiceApprovalUsersModel.fromJson(item))
          .toList();
      final requestData = await supabaseClient
          .from('requests_master')
          .insert(
            request.toJson(),
          )
          .select();
      final req = RequestMasterModel.fromJson(requestData.first);
      final approvalSequence = mapServiceApproversToApprovalSequence(
        requestId: req.requestId ?? -1,
        serviceApprovers: serviceApprovalUsers,
      );
      await supabaseClient
          .from('approval_sequence')
          .insert(
            approvalSequence.map((e) => e.toJson()).toList(),
          )
          .select();
      final blogData = await supabaseClient
          .from('blogs')
          .insert(
            blog.copyWith(requestId: req.requestId).toJson(),
          )
          .select();
      return BlogModel.fromJson(blogData.first);
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
      final serviceAprovalUsersData = await supabaseClient
          .from('service_approval_users')
          .select('*')
          .eq('service_id', ServicesConstants.blogServiceId)
          .eq('is_active', true);
      final serviceApprovalUsers = serviceAprovalUsersData
          .map((item) => ServiceApprovalUsersModel.fromJson(item))
          .toList();
      await supabaseClient
          .from('blogs')
          .update({
            'updated_at': DateTime.now().toIso8601String(),
            'title': blogViewerPage.title,
            'content': blogViewerPage.content,
            'topics': blogViewerPage.topics,
          })
          .eq(
            'id',
            blogViewerPage.blogId!,
          ) // Ensure you update the correct row
          .select();
      await supabaseClient
          .from('requests_master')
          .update({
            'status': blogViewerPage.createdById == updatedBy
                ? LookupConstants.requestStatusPending
                : blogViewerPage.requestStatusId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq(
            'request_id',
            blogViewerPage.requestId!,
          ) // Ensure you update the correct row
          .select();
      if (blogViewerPage.createdById == updatedBy) {
        final approvalSequence = mapServiceApproversToApprovalSequence(
          requestId: blogViewerPage.requestId!,
          serviceApprovers: serviceApprovalUsers,
        );
        await supabaseClient
            .from('approval_sequence')
            .update({
              'is_active': false,
            })
            .eq(
              'request_id',
              blogViewerPage.requestId!,
            ) // Ensure you update the correct row
            .select();
        await supabaseClient
            .from('approval_sequence')
            .insert(
              approvalSequence.map((e) => e.toJson()).toList(),
            )
            .select();
        await supabaseClient
            .from('request_unlocked_fields')
            .update({
              'is_active': false,
            })
            .eq('request_id',
                blogViewerPage.requestId!) // Ensure you update the correct row
            .select();
      }
      final blogsView = await supabaseClient
          .from('blogs_page_view')
          .select('*')
          .eq('request_is_active', true)
          .eq(
            'request_id',
            blogViewerPage.requestId!,
          );
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq(
            'request_id',
            blogViewerPage.requestId!,
          )
          .eq('is_active', true);
      return BlogViewerPageEntity(
        blogsView:
            blogsView.map((blog) => BlogsPageViewModel.fromJson(blog)).first,
        approval: approvalsView
            .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
            .toList(),
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
      updateApprovalSequenceDS(
        approvalSequence: approvalSequence,
        requestUnlockedFields: requestUnlockedFields,
        supabaseClient: supabaseClient,
      );
      final blogsView = await supabaseClient
          .from('blogs_page_view')
          .select('*')
          .eq('request_is_active', true)
          .eq(
            'request_id',
            approvalSequence.requestId!,
          );
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq(
            'request_id',
            blog.requestId!,
          )
          .eq('is_active', true);
      return BlogViewerPageEntity(
        blogsView:
            blogsView.map((blog) => BlogsPageViewModel.fromJson(blog)).first,
        approval: approvalsView
            .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
            .toList(),
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
          .match(filters);

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

      final result = await supabaseClient
          .from('blogs_page_view')
          .select('*')
          .match(filters);

      return result.map((blog) => BlogsPageViewModel.fromJson(blog)).first;
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
          .eq('is_active', true)
          .select('*');
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
          .eq('is_active', true)
          .select('*');
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
