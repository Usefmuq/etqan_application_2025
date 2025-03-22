import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogs implements Usecase<BlogPageEntity, NoParams> {
  final BlogRepository blogRepostory;
  GetAllBlogs(this.blogRepostory);
  @override
  Future<Either<Failure, BlogPageEntity>> call(NoParams params) async {
    return await blogRepostory.getAllBlogs();
  }
}
