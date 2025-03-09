import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
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
  final GetAllBlogs _getAllBlogs;
  BlogBloc({
    required SubmitBlog submitBlog,
    required UpdateBlog updateBlog,
    required GetAllBlogs getAllBlogs,
  })  : _submitBlog = submitBlog,
        _updateBlog = updateBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogSubmitEvent>(_onBlogSubmitEvent);
    on<BlogUpdateEvent>(_onBlogUpdateEvent);
    on<BlogGetAllBlogsEvent>(_onBlogGetAllBlogsEvent);
  }

  void _onBlogSubmitEvent(
    BlogSubmitEvent event,
    Emitter<BlogState> emit,
  ) async {
    final response = await _submitBlog(SubmitBlogParams(
      createdById: event.createdById,
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
      title: event.title,
      content: event.content,
      topics: event.topics,
    ));
    response.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (blog) {
        emit(BlogUpdateSuccess());
      },
    );
  }

  void _onBlogGetAllBlogsEvent(
    BlogGetAllBlogsEvent event,
    Emitter<BlogState> emit,
  ) async {
    final response = await _getAllBlogs(NoParams());
    response.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (blogs) {
        emit(BlogShowAllSuccess(blogs));
      },
    );
  }
}
