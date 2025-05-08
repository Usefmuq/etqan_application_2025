import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> submitBlog(BlogModel blog, RequestMasterModel request);
  Future<BlogViewerPageEntity> updateBlog(BlogModel blog);
  Future<BlogViewerPageEntity> approveBlog(
    ApprovalSequenceViewModel approvalSequence,
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
  Future<BlogViewerPageEntity> updateBlog(BlogModel blog) async {
    try {
      await supabaseClient
          .from('blogs')
          .update(
            blog.toJson(),
          )
          .eq('id', blog.id) // Ensure you update the correct row
          .select();
      final blogsView = await supabaseClient
          .from('blogs_page_view')
          .select('*')
          .eq('request_is_active', true)
          .eq(
            'request_id',
            blog.requestId,
          );
      final approvalsView = await supabaseClient
          .from('approval_sequence_view')
          .select('*')
          .eq(
            'request_id',
            blog.requestId,
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
      BlogsPageViewModel blog) async {
    try {
      final approval = await supabaseClient
          .from('approval_sequence')
          .update({
            'approver_comment': approvalSequence.approverComment,
            'approval_status': approvalSequence.approvalStatus,
            'approved_by': approvalSequence.approvedBy,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq(
              'approval_id',
              approvalSequence
                  .approvalId!) // Ensure you approve the correct row
          .select();
      final nextApproval = await supabaseClient
          .from('approval_sequence')
          .update({
            'approval_status': LookupConstants.approvalStatusApprovalPending,
          })
          .eq(
            'request_id',
            approvalSequence.requestId!,
          ) // Ensure you approve the correct row
          .eq(
            'approval_order',
            approvalSequence.approvalOrder! + 1,
          ) // Ensure you approve the correct row
          .eq(
            'approval_status',
            LookupConstants.approvalStatusApprovalQueued,
          ) // Ensure you approve the correct row
          .eq(
            'is_active',
            true,
          ) // Ensure you approve the correct row
          .select();
      if (nextApproval.isEmpty && approval.isNotEmpty) {
        await supabaseClient
            .from('requests_master')
            .update({
              'status': LookupConstants.requestStatusCompleted,
            })
            .eq(
              'request_id',
              approvalSequence.requestId!,
            )
            .select();
      }
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
          if (departmentId == null) {
            return [];
          }
          filters['department_id'] = departmentId;
        } else if (isManagerExpanded) {
          filters['report_to'] = userId;
        } else {
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
          .select('*');
      return approvalsView
          .map((approvals) => ApprovalSequenceViewModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
