import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/todo_list_controller.dart';
import 'todo_list_item.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => TodoListScreenState();
}

class TodoListScreenState extends ConsumerState<TodoListScreen> {
  late final TextEditingController _tagController;
  List<String> _selectedTags = [];
  Set<String> _availableTags = {};

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
    _fetchAvailableTags();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableTags() async {
    final todos = ref.read(todoListControllerProvider).valueOrNull ?? [];
    setState(() {
      _availableTags = todos.expand((todo) => todo.tags).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoListState = ref.watch(todoListControllerProvider);
    final filteredTodos = todoListState.when(
      data: (todos) => ref
          .read(todoListControllerProvider.notifier)
          .filterTodosByTags(todos, _selectedTags),
      error: (error, stackTrace) => [],
      loading: () => [],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Column(
        children: [
          // Tag Management Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration:
                        const InputDecoration(hintText: 'Enter new tag'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newTag = _tagController.text.trim();
                    if (newTag.isNotEmpty) {
                      ref
                          .read(todoListControllerProvider.notifier)
                          .addAvailableTag(newTag);
                      _tagController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          // ... Tag Filter Section (modified) ...
          Wrap(
            spacing: 8.0,
            children: ref
                .watch(todoListControllerProvider.notifier)
                .availableTags
                .map((tag) {
              return FilterChip(
                label: Text(tag),
                selected: _selectedTags.contains(tag),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                onDeleted: () {
                  ref
                      .read(todoListControllerProvider.notifier)
                      .removeAvailableTag(tag);
                  // Also remove the tag from _selectedTags if it was selected
                  if (_selectedTags.contains(tag)) {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  }
                },
              );
            }).toList(),
          ),
          // Todo List Section
          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(child: Text('No Todos yet!'))
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return ProviderScope(
                          overrides: [currentTodo.overrideWithValue(todo)],
                          child: const TodoListItem());
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newTodoDescription = '';
              List<String> selectedTagsForNewTodo = [];

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Add Todo'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (value) => newTodoDescription = value,
                          decoration: const InputDecoration(
                              hintText: 'Enter todo description'),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8.0,
                          children: _availableTags.map((tag) {
                            return FilterChip(
                              label: Text(tag),
                              selected: selectedTagsForNewTodo.contains(tag),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedTagsForNewTodo.add(tag);
                                  } else {
                                    selectedTagsForNewTodo.remove(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (newTodoDescription.isNotEmpty) {
                            ref
                                .read(todoListControllerProvider.notifier)
                                .addTodo(
                                    newTodoDescription, selectedTagsForNewTodo);
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
          );
        },
        child: const Icon(Icons.add),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: const Text('Todo List')),
    //   body: todoListState.when(
    //     data: (todos) => todos.isEmpty
    //         ? const Center(child: Text('No Todos yet!'))
    //         : ListView.builder(
    //             itemCount: todos.length,
    //             itemBuilder: (context, index) {
    //               final todo = todos[index];
    //               return ProviderScope(
    //                   overrides: [currentTodo.overrideWithValue(todo)],
    //                   child: const TodoListItem());
    //             },
    //           ),
    //     error: (error, stackTrace) => Center(child: Text('Error: $error')),
    //     loading: () => const Center(child: CircularProgressIndicator()),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           String newTodoDescription = '';
    //           return AlertDialog(
    //             title: const Text('Add Todo'),
    //             content: TextField(
    //               onChanged: (value) => newTodoDescription = value,
    //               decoration:
    //                   const InputDecoration(hintText: 'Enter todo description'),
    //             ),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context),
    //                 child: const Text('Cancel'),
    //               ),
    //               TextButton(
    //                 onPressed: () {
    //                   if (newTodoDescription.isNotEmpty) {
    //                     ref
    //                         .read(todoListControllerProvider.notifier)
    //                         .addTodo(newTodoDescription);
    //                     Navigator.pop(context);
    //                   }
    //                 },
    //                 child: const Text('Add'),
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     },
    //     child: const Icon(Icons.add),
    //   ),
    // );
  }
}
