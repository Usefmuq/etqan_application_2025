import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel({
    required super.id,
    required super.createdById,
    required super.updatedAt,
    required super.title,
    required super.content,
    required super.topics,
    super.createdByName,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_by_id': createdById,
      'updated_at': updatedAt.toIso8601String(),
      'title': title,
      'content': content,
      'topics': topics,
    };
  }

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String,
      createdById: map['created_by_id'] as String,
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      title: map['title'] as String,
      content: map['content'] as String,
      topics: List<String>.from(map['topics'] ?? []),
    );
  }

  BlogModel copyWith({
    String? id,
    String? createdById,
    DateTime? updatedAt,
    String? title,
    String? content,
    List<String>? topics,
    String? createdByName,
  }) {
    return BlogModel(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      content: content ?? this.content,
      topics: topics ?? this.topics,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}
