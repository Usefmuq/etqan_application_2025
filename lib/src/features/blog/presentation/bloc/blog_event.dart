part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogSubmitEvent extends BlogEvent {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  BlogSubmitEvent({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class BlogUpdateEvent extends BlogEvent {
  final String id;
  final String createdById;
  final String status;
  final int requestId;
  final bool isActive;
  final String title;
  final String content;
  final List<String> topics;

  BlogUpdateEvent({
    required this.id,
    required this.createdById,
    required this.status,
    required this.requestId,
    required this.isActive,
    required this.title,
    required this.content,
    required this.topics,
  });
}

final class BlogApproveEvent extends BlogEvent {
  // final int approvalId;
  // final String approverUserId;
  // final String approvalStatus;
  // final int requestId;
  // final bool isActive;
  // final String approverComment;
  final ApprovalSequenceViewModel approvalSequence;
  final List<RequestUnlockedField>? requestUnlockedFields;
  final BlogsPageViewModel blogModel;

  BlogApproveEvent({
    required this.approvalSequence,
    this.requestUnlockedFields,
    required this.blogModel,
  });
}

final class BlogGetAllBlogsEvent extends BlogEvent {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;
  BlogGetAllBlogsEvent({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}
