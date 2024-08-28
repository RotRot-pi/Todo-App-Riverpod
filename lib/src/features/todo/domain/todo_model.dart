import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String description;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  @override
  List<Object> get props => [id, description, isCompleted];

  Todo copyWith({
    String? id,
    String? description,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
