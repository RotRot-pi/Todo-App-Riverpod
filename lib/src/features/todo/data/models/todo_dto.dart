import 'dart:convert';

import 'package:todo_riverpod/src/features/todo/domain/todo_model.dart';

class TodoDto {
  final String id;
  final String description;
  final bool isCompleted;

  TodoDto({
    required this.id,
    required this.description,
    required this.isCompleted,
  });

  factory TodoDto.fromDomain(Todo todo) {
    return TodoDto(
      id: todo.id,
      description: todo.description,
      isCompleted: todo.isCompleted,
    );
  }

  factory TodoDto.fromJson(String json) {
    final map = jsonDecode(json);
    return TodoDto(
      id: map['id'] as String,
      description: map['description'] as String,
      isCompleted: map['isCompleted'] as bool,
    );
  }

  Todo toDomain() {
    return Todo(
      id: id,
      description: description,
      isCompleted: isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}
