import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/entities/request_master.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';

class BlogViewerPageEntity {
  final Blog blog;
  final RequestMaster? request;
  final List<ApprovalSequence>? approval;

  BlogViewerPageEntity({
    required this.blog,
    this.request,
    this.approval,
  });
}
