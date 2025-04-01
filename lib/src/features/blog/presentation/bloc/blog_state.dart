part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogFailure extends BlogState {
  final String error;
  BlogFailure(this.error);
}

final class BlogSubmitSuccess extends BlogState {}

final class BlogUpdateSuccess extends BlogState {
  final BlogViewerPageEntity blogViewerPageEntity;
  BlogUpdateSuccess(this.blogViewerPageEntity);
}

final class BlogApproveSuccess extends BlogState {
  final BlogViewerPageEntity blogViewerPageEntity;
  BlogApproveSuccess(this.blogViewerPageEntity);
}

final class BlogShowAllSuccess extends BlogState {
  final BlogPageEntity blogPage;
  BlogShowAllSuccess(this.blogPage);
}
