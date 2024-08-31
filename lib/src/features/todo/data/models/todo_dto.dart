import 'dart:convert';

import 'package:todo_riverpod/src/features/todo/domain/todo_model.dart';

class TodoDto {
  final String id;
  final String description;
  final bool isCompleted;

  final List<String> tags;

  TodoDto({
    required this.id,
    required this.description,
    required this.isCompleted,
    required this.tags,
  });

  factory TodoDto.fromDomain(Todo todo) {
    return TodoDto(
      id: todo.id,
      description: todo.description,
      isCompleted: todo.isCompleted,
      tags: todo.tags,
    );
  }

  factory TodoDto.fromJson(String json) {
    final map = jsonDecode(json);
    return TodoDto(
      id: map['id'] as String,
      description: map['description'] as String,
      isCompleted: map['isCompleted'] as bool,
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  Todo toDomain() {
    return Todo(
      id: id,
      description: description,
      isCompleted: isCompleted,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
      'tags': tags,
    };
  }
}
