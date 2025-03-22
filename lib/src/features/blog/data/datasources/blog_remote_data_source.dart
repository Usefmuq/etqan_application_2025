import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_approval_users_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> submitBlog(BlogModel blog, RequestMasterModel request);
  Future<BlogModel> updateBlog(BlogModel blog);
  Future<BlogModel> approveBlog(
    ApprovalSequenceModel approvalSequence,
    BlogModel blog,
  );
  Future<List<BlogModel>> getAllBlogs();
  Future<List<RequestMasterModel>> getAllRequests();
  Future<List<ApprovalSequenceModel>> getAllApprovals();
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
  Future<BlogModel> updateBlog(BlogModel blog) async {
    try {
      final blogData = await supabaseClient
          .from('blogs')
          .update(
            blog.toJson(),
          )
          .eq('id', blog.id) // Ensure you update the correct row
          .select();
      return BlogModel.fromJson(blogData.first);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BlogModel> approveBlog(
      ApprovalSequenceModel approvalSequence, BlogModel blog) async {
    try {
      final blogData = await supabaseClient
          .from('blogs')
          .update(
            blog.toJson(),
          )
          .eq('id', blog.id) // Ensure you approve the correct row
          .select();
      return BlogModel.fromJson(blogData.first);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs = await supabaseClient
          .from('blogs')
          .select('*, users (first_name_en, last_name_en)');
      return blogs
          .map((blog) => BlogModel.fromJson(blog).copyWith(
                createdByName:
                    "${blog['users']['first_name_en']} ${blog['users']['last_name_en']}",
              ))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<RequestMasterModel>> getAllRequests() async {
    try {
      final requests = await supabaseClient
          .from('requests_master')
          .select('*')
          .eq('service_id', ServicesConstants.blogServiceId);
      return requests
          .map((requests) => RequestMasterModel.fromJson(requests))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApprovalSequenceModel>> getAllApprovals() async {
    try {
      final approvals = await supabaseClient
          .from('approval_sequence')
          .select('*')
          .eq('requests_master.service_id', ServicesConstants.blogServiceId)
          .select('*, requests_master!inner(service_id)');
      return approvals
          .map((approvals) => ApprovalSequenceModel.fromJson(approvals))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
