import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/todo_model.dart';
import '../controllers/todo_list_controller.dart';

final currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

class TodoListItem extends ConsumerWidget {
  const TodoListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(currentTodo);
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (value) =>
            ref.read(todoListControllerProvider.notifier).toggleTodo(todo.id),
      ),
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          ref
              .read<TodoListController>(todoListControllerProvider.notifier)
              .deleteTodo(todo.id);
        },
      ),
    );
  }
}
