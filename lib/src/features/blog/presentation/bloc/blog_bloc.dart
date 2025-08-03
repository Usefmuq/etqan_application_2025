import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/approve_blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/submit_blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/update_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final SubmitBlog _submitBlog;
  final UpdateBlog _updateBlog;
  final ApproveBlog _approveBlog;
  final GetAllBlogs _getAllBlogs;
  BlogBloc({
    required SubmitBlog submitBlog,
    required UpdateBlog updateBlog,
    required ApproveBlog approveBlog,
    required GetAllBlogs getAllBlogs,
  })  : _submitBlog = submitBlog,
        _updateBlog = updateBlog,
        _approveBlog = approveBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogSubmitEvent>(_onBlogSubmitEvent);
    on<BlogUpdateEvent>(_onBlogUpdateEvent);
    on<BlogApproveEvent>(_onBlogApproveEvent);
    on<BlogGetAllBlogsEvent>(_onBlogGetAllBlogsEvent);
  }

  void _onBlogSubmitEvent(
    BlogSubmitEvent event,
    Emitter<BlogState> emit,
  ) async {
    final response = await _submitBlog(SubmitBlogParams(
      createdById: event.createdById,
      // status: event.status,
      // requestId: event.requestId,
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (blog) {
        emit(BlogSubmitSuccess());
      },
    );
  }

  void _onBlogUpdateEvent(
    BlogUpdateEvent event,
    Emitter<BlogState> emit,
  ) async {
    final response = await _updateBlog(UpdateBlogParams(
      id: event.id,
      createdById: event.createdById,
      status: event.status,
      requestId: event.requestId,
      isActive: event.isActive,
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (blog) {
        emit(BlogUpdateSuccess(blog));
      },
    );
  }

  void _onBlogApproveEvent(
    BlogApproveEvent event,
    Emitter<BlogState> emit,
  ) async {
    final response = await _approveBlog(ApproveBlogParams(
      approvalSequenceModel: event.approvalSequence,
      requestUnlockedFields: event.requestUnlockedFields,
      blogModel: event.blogModel,
    ));
    response.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (blog) {
        emit(BlogApproveSuccess(blog));
      },
    );
  }

  void _onBlogGetAllBlogsEvent(
    BlogGetAllBlogsEvent event,
    Emitter<BlogState> emit,
  ) async {
    final response = await _getAllBlogs(GetAllBlogsParams(
      user: event.user,
      departmentId: event.departmentId,
      isManagerExpanded: event.isManagerExpanded,
      isDepartmentManagerExpanded: event.isDepartmentManagerExpanded,
      isViewAll: event.isViewAll,
    ));
    response.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (blogs) {
        emit(BlogShowAllSuccess(blogs));
      },
    );
  }
}
