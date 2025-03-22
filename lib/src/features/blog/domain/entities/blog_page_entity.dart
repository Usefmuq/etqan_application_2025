import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/entities/request_master.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';

class BlogPageEntity {
  final List<Blog> blogs;
  final List<RequestMaster> requests;
  final List<ApprovalSequence> approvals;

  BlogPageEntity({
    required this.blogs,
    required this.requests,
    required this.approvals,
  });
}
