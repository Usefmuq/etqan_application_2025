part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogSubmitEvent extends BlogEvent {
  final String createdById;
  final String title;
  final String content;
  final List<String> topics;

  BlogSubmitEvent({
    required this.createdById,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class BlogUpdateEvent extends BlogEvent {
  final String id;
  final String createdById;
  final String title;
  final String content;
  final List<String> topics;

  BlogUpdateEvent({
    required this.id,
    required this.createdById,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class BlogGetAllBlogsEvent extends BlogEvent {}
