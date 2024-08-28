import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/todo_list_controller.dart';
import 'todo_list_item.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListState = ref.watch(todoListControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: todoListState.when(
        data: (todos) => todos.isEmpty
            ? const Center(child: Text('No Todos yet!'))
            : ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ProviderScope(
                      overrides: [
                        currentTodo.overrideWithValue(todo)
                      ],
                      child: const TodoListItem()
                  );
                },
              ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newTodoDescription = '';
              return AlertDialog(
                title: const Text('Add Todo'),
                content: TextField(
                  onChanged: (value) => newTodoDescription = value,
                  decoration: const InputDecoration(hintText: 'Enter todo description'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (newTodoDescription.isNotEmpty) {
                        ref.read(todoListControllerProvider.notifier).addTodo(newTodoDescription);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
