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
    final isToggling = ref.watch(todoListControllerProvider).isLoading;

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => ref
                .read(todoListControllerProvider.notifier)
                .toggleTodo(todo.id),
          ),
          if (isToggling) // Show loading indicator while toggling
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: todo.tags.isNotEmpty
          ? Wrap(
              spacing: 4.0,
              children: todo.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade100,
                  onDeleted: () {
                    ref
                        .read(todoListControllerProvider.notifier)
                        .removeTagFromTodo(todo.id, tag);
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              }).toList(),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () =>
            ref.read(todoListControllerProvider.notifier).deleteTodo(todo.id),
      ),
    );
  }
}
// class TodoListItem extends ConsumerWidget {
//   const TodoListItem({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final todo = ref.watch(currentTodo);
//     return ListTile(
//       leading: Checkbox(
//         value: todo.isCompleted,
//         onChanged: (value) =>
//             ref.read(todoListControllerProvider.notifier).toggleTodo(todo.id),
//       ),
//       title: Text(
//         todo.description,
//         style: TextStyle(
//           decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
//         ),
//       ),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () async {
//               String updatedDescription = todo.description;
//               await showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text('Edit Todo'),
//                     content: TextField(
//                       onChanged: (value) => updatedDescription = value,
//                       decoration: const InputDecoration(
//                           hintText: 'Enter todo description'),
//                       controller: TextEditingController(text: todo.description),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Cancel'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           if (updatedDescription.isNotEmpty) {
//                             final updatedTodo =
//                                 todo.copyWith(description: updatedDescription);
//                             ref
//                                 .read(todoListControllerProvider.notifier)
//                                 .updateTodo(updatedTodo);
//                             Navigator.pop(context);
//                           }
//                         },
//                         child: const Text('Save'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () => ref
//                 .read(todoListControllerProvider.notifier)
//                 .deleteTodo(todo.id),
//           ),
//         ],
//       ),
//     );
//   }
// }
