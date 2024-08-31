import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String description;
  final bool isCompleted;
  final List<String> tags;

  Todo({
    required this.id,
    required this.description,
    this.isCompleted = false,
    this.tags = const [],
  });

  @override
  List<Object> get props => [id, description, isCompleted, tags];

  Todo copyWith({
    String? id,
    String? description,
    bool? isCompleted,
    List<String>? tags,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? this.tags,
    );
  }
}
